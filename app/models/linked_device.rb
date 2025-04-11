class LinkedDevice < ApplicationRecord
  include RandomId

  belongs_to :user
  has_many :linked_device_linkables, dependent: :destroy
  has_many :event_linkables, -> { where(linkable_type: "Event") },
    class_name: "LinkedDeviceLinkable"
  has_many :band_linkables, -> { where(linkable_type: "Band") },
    class_name: "LinkedDeviceLinkable"
  has_many :member_linkables, -> { where(linkable_type: "Member") },
    class_name: "LinkedDeviceLinkable"

  enum :device_type, {
    api: 0,
    web: 1,
    ical: 2
  }

  validates :name, presence: true
  validates :device_type, presence: true
  validates :secret, presence: true, uniqueness: true

  before_validation :generate_secret, on: :create
  before_destroy :ensure_never_accessed

  scope :active, -> { where(revoked_at: nil) }
  scope :revoked, -> { where.not(revoked_at: nil) }

  # For checkboxes
  attr_accessor :event_ids, :band_ids, :member_ids, :user_account

  # Skip validation flag - used in tests
  attr_accessor :skip_access_validation
  alias_method :skip_access_validation?, :skip_access_validation

  def skip_access_validation!
    @skip_access_validation = true
  end

  # Dynamic getters for linkable IDs
  %w[event band member].each do |resource|
    define_method(:"#{resource}_ids") do
      instance_variable_get(:"@#{resource}_ids") ||
        send(:"#{resource}_linkables").map { |l| l.linkable_id.to_s }
    end

    define_method(:"#{resource}_ids=") do |ids|
      instance_variable_set(:"@#{resource}_ids", Array(ids).compact_blank.map(&:to_s))
    end
  end

  # Process the IDs after save
  after_save :process_linkables

  def revoked?
    revoked_at.present?
  end

  def revoke!
    update!(revoked_at: Time.current)
  end

  def touch_access!
    update!(last_accessed_at: Time.current)
  end

  def accessed?
    last_accessed_at.present?
  end

  def has_specific_access?
    linked_device_linkables.any?
  end

  def access_type
    has_specific_access? ? "specific" : "full"
  end

  private

  def generate_secret
    self.secret ||= SecureRandom.hex(32)
  end

  def ensure_never_accessed
    if last_accessed_at.present?
      errors.add(:base, "Cannot delete a device that has been accessed")
      throw :abort
    end
  end

  def process_linkables
    return unless persisted?

    %w[Event Band Member].each do |type|
      process_linkable_type(type, send(:"#{type.downcase}_ids"))
    end
  end

  def process_linkable_type(type, ids)
    current = send(:"#{type.downcase}_linkables")
    current_ids = current.pluck(:linkable_id).map(&:to_s)

    new_linkables = ids - current_ids
    new_linkables.each do |id|
      linked_device_linkables.create!(
        linkable_type: type,
        linkable_id: id
      )
    end

    old_linkables = current_ids - ids
    current.where(linkable_id: old_linkables).destroy_all
  end
end
