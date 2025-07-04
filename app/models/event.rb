class Event < ApplicationRecord
  include EventsHelper
  include RandomId

  has_many :event_bands, dependent: :destroy
  has_many :bands, through: :event_bands
  has_many :permissions, as: :item, dependent: :destroy
  has_many :linked_devices, as: :linkable, dependent: :nullify
  has_many :events_audits, dependent: :destroy
  validate :end_date_nil_or_after_start
  before_validation :set_defaults

  attribute :permission_type, :string

  scope :past, -> { where(<<~SQL) }
    start_date IS NULL OR
    COALESCE(end_date, start_date) <= CURRENT_TIMESTAMP
  SQL

  scope :future, -> { where(<<~SQL) }
    start_date IS NULL OR
    COALESCE(end_date, start_date) >= CURRENT_TIMESTAMP
  SQL

  scope :permitted_for, ->(user_id) {
    select(
      "events.*, #{EventPermissionQuery.with_permission_type_sql(user_id)}"
    )
      .where(EventPermissionQuery.permission_sql(user_id))
  }

  include Auditable
  audit_log_columns :name, :description, :start_date, :end_date

  def owner
    permissions.where(status: :owned).first&.user
  end

  def url
    Rails.application.routes.url_helpers.edit_event_path(self)
  end

  def external_url
    Rails.application.routes.url_helpers.edit_event_url(self, host: Rails.application.config.server_url)
  end

  def editable?
    permission_type == "edit"
  end

  def duration
    if start_date.present? && end_date.present?
      convert_seconds_to_duration(end_date - start_date)
    end
  end

  private

  def set_defaults
    if start_date.present?
      self.end_date ||= start_date
      if end_date && end_date < start_date
        self.end_date = start_date
      end
    end
  end

  def end_date_nil_or_after_start
    if end_date.present? && start_date.present? && end_date < start_date
      errors.add(:end_date, "Must be before start")
    end
  end
end
