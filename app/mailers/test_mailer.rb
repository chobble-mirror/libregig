class TestMailer < ApplicationMailer
  def test_email(to)
    Rails.logger.info "Preparing to send test email to #{to}."

    mail(
      to: to,
      subject: "Test Email",
      body: "This is a test email."
    )
  end
end
