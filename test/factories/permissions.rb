FactoryBot.define do
  factory :permission do
    association :user, factory: :user, user_type: :member
    association :bestowing_user, factory: :user, user_type: :organiser

    item { association(:event) }

    permission_type { "edit" }
    status { :accepted }

    trait :for_event do
      item { association(:event) }
    end

    trait :for_member do
      item { association(:member) }
    end

    trait :for_band do
      item { association(:band) }
    end

    factory :owned_permission do
      bestowing_user { nil }
      status { :owned }
    end
  end
end
