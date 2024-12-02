class ConfirmationToken < ApplicationRecord
  belongs_to :user

  before_create :set_expires_at, unless: :expires_at?

  validates :token, presence: true, uniqueness: true

  scope :valid, -> { where("expires_at > ?", Time.current) }

  private

  def set_expires_at
    self.expires_at = 24.hours.from_now
  end
end
