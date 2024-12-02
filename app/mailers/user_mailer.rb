# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
  CONFIRM_REGISTRATION_SUBJECT = "Thank you for joining Libregig"

  def confirm_registration(user_mail)
    @username = user_mail.params["username"]
    @url = user_mail.params["url"]

    mail(to: user_mail.recipient, subject: CONFIRM_REGISTRATION_SUBJECT)
  end

  def self.send_confirmation_registration(user)
    confirmation_token = user.confirmation_tokens.create!(token: SecureRandom.urlsafe_base64)

    user_mail = UserMail.new(
      user: user,
      recipient: user.email,
      subject: CONFIRM_REGISTRATION_SUBJECT,
      template: "confirm_registration",
      params: {
        username: user.username,
        url: generate_confirmation_url(confirmation_token)
      }
    )

    if user_mail.save
      SendMailJob.perform_later(user_mail.id)
    else
      errors = user_mail.errors.full_messages.join(", ")
      Rails.logger.error("Failed to create UserMail: #{errors}")
    end

    user_mail
  end

  def self.generate_confirmation_url(confirmation_token)
    Rails.application.routes.url_helpers.confirm_registration_url(
      token: confirmation_token.token,
      host: Rails.configuration.server_url
    )
  end
end
