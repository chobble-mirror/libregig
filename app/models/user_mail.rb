class UserMail < ApplicationRecord
  belongs_to :user

  enum :state, {pending: 0, sending: 1, sent: 2, failed: 3}

  validates :subject, presence: true, length: {maximum: 120}
  validates :recipient, presence: true, length: {maximum: 255}
  validates :template, presence: true, length: {maximum: 50}
  validates :params, presence: true

  def html_content
    content(:html)
  end

  def text_content
    content(:text)
  end

  def attempt_send
    return unless pending?

    update!(state: :sending)

    begin
      UserMailer.confirm_registration(self).deliver_now
      update!(state: :sent)
      Rails.logger.info("Mail sent successfully to #{recipient}.")
    rescue => e
      raise e if Rails.env.development?
      update!(state: :failed)
      Rails.logger.error("Failed to send mail to #{recipient}: #{e}")
    end
  end

  private

  def content(format)
    ApplicationController.render(
      layout: false,
      template: "user_mailer/#{template}",
      assigns: params,
      formats: [format]
    )
  end
end
