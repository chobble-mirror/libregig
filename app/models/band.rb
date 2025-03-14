class Band < ApplicationRecord
  include RandomId

  has_many :event_bands, dependent: :destroy
  has_many :events, through: :event_bands

  has_many :band_members, dependent: :restrict_with_error
  has_many :members, through: :band_members
  has_many :permission, as: :item, dependent: :destroy
  has_many :linked_devices, as: :linkable, dependent: :nullify

  validates :description, presence: true
  validates :name, presence: true

  include Auditable
  audit_log_columns :name, :description

  attribute :permission_type, :string

  scope :permitted_for, ->(user_id) {
    select(
      "bands.*, #{BandPermissionQuery.with_permission_type_sql(user_id)}"
    )
      .where(BandPermissionQuery.permission_sql(user_id))
  }

  def owner
    permission.where(status: :owned).first&.user
  end

  def url
    Rails.application.routes.url_helpers.edit_band_path(self)
  end

  def editable?
    permission_type == "edit"
  end
end
