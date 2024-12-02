namespace :email_test do
  desc "Send a test email to verify SMTP settings"
  task send: :environment do
    to = Rails.configuration.smtp_test_to

    if to.nil?
      puts <<~MSG
        Please provide a test 'to' email address with the TEST_EMAIL_TO
        environment variable in your .env file.
      MSG
      exit 1
    end

    begin
      TestMailer.test_email(to).deliver_now
      puts "Test email sent to #{to} successfully!"
    rescue => e
      puts "Failed to send test email: #{e.message}"
      puts Rails.configuration.action_mailer.inspect
      exit 1
    end
  end
end
