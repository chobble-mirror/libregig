FactoryBot.define do
  factory :confirmation_token do
    user
    token { SecureRandom.urlsafe_base64 }
    expires_at { 24.hours.from_now }
  end
end
