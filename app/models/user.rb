class User < ApplicationRecord
  include RandomId
  include PermissionsHelper

  enum :user_type, {admin: 0, member: 1, organiser: 2}

  has_secure_password
  has_many :permissions,
    dependent: :destroy,
    inverse_of: :user

  def members
    Member.permitted_for(id)
  end

  def bands
    Band.permitted_for(id)
  end

  def events
    Event.permitted_for(id)
  end

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

  private

  def password_required?
    new_record? || password.present?
  end

  def set_default_time_zone
    self.time_zone = "Etc/UTC" if time_zone.blank?
  end
end
