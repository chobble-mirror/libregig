FactoryBot.define do
  factory :user, class: User do
    sequence(:email) { |n| "factoryuser#{format("%05d", n)}@bash.coop" }
    sequence(:name) { |n| "user#{format("%05d", n)}" }
    sequence(:username) { |n| "user#{format("%05d", n)}" }
    password_digest { BCrypt::Password.create("password") }
    user_type { :member }
    confirmed { true }
    time_zone { "Etc/UTC" }

    factory :user_unconfirmed do
      confirmed { false }
    end

    factory :user_admin do
      user_type { :admin }
      sequence(:name) { |n| "admin user #{format("%05d", n)}" }
      sequence(:username) { |n| "admin_user_#{format("%05d", n)}" }
    end

    factory :user_member do
      user_type { :member }
      sequence(:name) { |n| "member user #{format("%05d", n)}" }
      sequence(:username) { |n| "member_user_#{format("%05d", n)}" }
    end

    factory :user_organiser do
      user_type { :organiser }
      sequence(:name) { |n| "organiser user #{format("%05d", n)}" }
      sequence(:username) { |n| "organiser_user_#{format("%05d", n)}" }
    end
  end
end
