FactoryBot.define do
  factory :linked_device do
    name { "Test Device" }
    device_type { :api }
    association :user
    user_account { "1" }
    
    trait :with_event do
      user_account { nil }
      after(:create) do |device, evaluator|
        event = create(:event)
        device.event_ids = [event.id]
        device.save!
      end
    end
    
    trait :with_band do
      user_account { nil }
      after(:create) do |device, evaluator|
        band = create(:band)
        device.band_ids = [band.id]
        device.save!
      end
    end
    
    trait :with_member do
      user_account { nil }
      after(:create) do |device, evaluator|
        member = create(:member)
        device.member_ids = [member.id]
        device.save!
      end
    end
    
    trait :revoked do
      revoked_at { Time.current }
    end
    
    trait :web do
      device_type { :web }
    end
  end
end