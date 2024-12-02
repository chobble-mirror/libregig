require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.server_url = ENV["SERVER_URL"]
  config.smtp_test_to = ENV["SMTP_TEST_TO"]
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: ENV["SMTP_ADDRESS"],
    port: Integer(ENV["SMTP_PORT"], exception: false) || 465,
    user_name: ENV["SMTP_USER_NAME"],
    password: ENV["SMTP_PASSWORD"],
    authentication: ENV["SMTP_AUTHENTICATION"]&.to_sym,
    enable_starttls: ENV["SMTP_ENABLE_STARTTLS"] == "true",
    openssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
  }
  config.action_mailer.logger = Rails.logger
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  config.action_mailer.default_url_options = {host: ENV["SERVER_HOST"]}
  config.action_mailer.default_options = {from: ENV["SMTP_FROM"]}
end
