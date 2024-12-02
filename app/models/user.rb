class User < ApplicationRecord
  enum :user_type, {admin: 0, member: 1, organiser: 2}

  has_secure_password
  has_many :permissions,
    dependent: :destroy,
    inverse_of: :user

  has_many :owned_bands, -> { where(permissions: {item_type: "Band", status: :owned}) },
    through: :permissions,
    source: :item,
    source_type: "Band"

  has_many :owned_events, -> { where(permissions: {item_type: "Event", status: :owned}) },
    through: :permissions,
    source: :item,
    source_type: "Event"

  has_many :owned_members, -> { where(permissions: {item_type: "Member", status: :owned}) },
    through: :permissions,
    source: :item,
    source_type: "Member"

  has_many :confirmation_tokens, dependent: :destroy

  before_save { email&.downcase! }
  before_validation :set_default_time_zone

  validates :username,
    presence: true,
    uniqueness: true

  validates :email,
    presence: {message: "can't be blank"},
    uniqueness: true,
    format: {with: URI::MailTo::EMAIL_REGEXP, message: "is invalid", allow_blank: true}

  validates :password,
    presence: true,
    length: {minimum: 6},
    if: :password_required?,
    allow_blank: true

  validates :password_confirmation,
    presence: true,
    allow_blank: true

  validates :time_zone,
    inclusion: {
      in: ActiveSupport::TimeZone.all.map { |t| t.tzinfo.name },
      message: "%{value} is not a valid time zone"
    }, allow_blank: true

  def confirmed?
    confirmed || admin?
  end

  def to_param
    username
  end

  def owned_links
    return @owned_links if defined?(@owned_links)
    @owned_links =
      bands.select(:name, :id) +
      events.select(:name, :id) +
      members.select(:name, :id)
  end

  def bands
    return @bands if defined?(@bands)
    @bands =
      admin? ?
        Band.all :
        Band.where(id: band_permissions.map(&:item_id))
  end

  def events
    return @events if defined?(@events)
    @events =
      admin? ?
        Event.all :
        Event.where(id: event_permissions.map(&:item_id))
  end

  def members
    return @members if defined?(@members)
    @members =
      admin? ?
        Member.all :
        Member.where(id: member_permissions.map(&:item_id))
  end

  private

  def password_required?
    new_record? || password.present?
  end

  def event_permissions
    permissions.where(status: [:accepted, :owned], item_type: "Event")
  end

  def band_permissions
    permissions.where(status: [:accepted, :owned], item_type: "Band")
  end

  def member_permissions
    permissions.where(status: [:accepted, :owned], item_type: "Member")
  end

  def set_default_time_zone
    self.time_zone = "Etc/UTC" if time_zone.blank?
  end
end
