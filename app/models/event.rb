class Event < ApplicationRecord
  has_many :event_bands, dependent: :destroy
  has_many :bands, through: :event_bands
  has_many :permissions, as: :item, dependent: :destroy

  scope :past, -> { where("date <= CURRENT_TIMESTAMP") }
  scope :future, -> { where("date >= CURRENT_TIMESTAMP") }

  include Auditable
  audit_log_columns :name, :description, :date

  def owner
    permissions.where(status: :owned).first&.user
  end

  def url
    Rails.application.routes.url_helpers.edit_event_path(self)
  end

  def external_url
    Rails.application.routes.url_helpers.edit_event_url(self, host: Rails.application.config.server_url)
  end
end
