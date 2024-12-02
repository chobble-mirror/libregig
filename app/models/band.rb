class Band < ApplicationRecord
  has_many :event_bands, dependent: :destroy
  has_many :events, through: :event_bands

  has_many :band_members, dependent: :restrict_with_error
  has_many :members, through: :band_members
  has_many :permission, as: :item, dependent: :destroy

  validates :description, presence: true
  validates :name, presence: true

  include Auditable
  audit_log_columns :name, :description

  def owner
    permissions.where(status: :owned).first&.user
  end

  def url
    Rails.application.routes.url_helpers.edit_band_path(self)
  end
end
