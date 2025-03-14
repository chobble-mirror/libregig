FactoryBot.define do
  factory :linked_device_linkable do
    association :linked_device

    trait :for_event do
      association :linkable, factory: :event
      linkable_type { "Event" }
    end

    trait :for_band do
      association :linkable, factory: :band
      linkable_type { "Band" }
    end

    trait :for_member do
      association :linkable, factory: :member
      linkable_type { "Member" }
    end
  end
end
