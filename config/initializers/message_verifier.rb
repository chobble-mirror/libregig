Rails.application.config.to_prepare do
  secret_key_base = Rails.application.secret_key_base
  Rails.application.config.message_verifier =
    ActiveSupport::MessageVerifier.new(secret_key_base)
end
