class Permission < ApplicationRecord
  include RandomId
  include PermissionsHelper

  belongs_to :user, class_name: "User"
  belongs_to :bestowing_user, class_name: "User", optional: true
  belongs_to :item, polymorphic: true

  scope :accepted, -> { where(status: :accepted) }
  scope :accepted_or_owned, -> { where(status: %i[accepted owned]) }
  scope :item_type, ->(type) { where(item_type: type) }
  scope :for_user, ->(user) { where("bestowing_user_id = :user_id OR user_id = :user_id", user_id: user.id) }

  def self.join_models(model)
    table_name = model.to_s.pluralize
    klass_name = model.to_s.classify
    joins("
        JOIN #{table_name}
        ON #{table_name}.id = permissions.item_id
        AND permissions.item_type = '#{klass_name}'
    ")
  end

  scope :bands, -> { join_models(:band) }
  scope :events, -> { join_models(:event) }
  scope :members, -> { join_models(:member) }

  scope :system_permissions, -> { where(bestowing_user: nil) }

  validates :item_type, presence: true
  validates :permission_type, presence: true, inclusion: {in: %w[view edit]}
  validates :status, presence: true, inclusion: {in: %w[owned pending accepted rejected]}
  validate :bestowing_user_must_be_organiser_or_nil, :user_must_be_member_or_organiser

  validate :valid_item
  validate :valid_user

  enum :status, {
    owned: "owned",
    pending: "pending",
    accepted: "accepted",
    rejected: "rejected"
  }

  private

  def valid_item
    return true if bestowing_user.nil?

    item_ids = potential_items(bestowing_user).pluck(1)
    item_str = "#{item_type}_#{item_id}"

    unless item_ids.include?(item_str)
      errors.add(:item, "is not a valid selection for #{bestowing_user}. Valid options: #{item_ids}")
    end
  end

  def valid_user
    # TODO: make this fancier
    unless User.find(user_id)
      errors.add(:user, "is not a valid selection")
    end
  end

  def bestowing_user_must_be_organiser_or_nil
    unless bestowing_user.nil? || bestowing_user.organiser?
      errors.add(:bestowing_user, "must be an organiser")
    end
  end

  def user_must_be_member_or_organiser
    unless user&.organiser? || user&.member?
      errors.add(:user, "must be a member or organiser")
    end
  end
end
