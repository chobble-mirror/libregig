FactoryBot.define do
  factory :event, class: Event do
    sequence(:name) { |n| "Event #{format("%05d", n)}" }
    sequence(:description) { |n| "Event #{format("%05d", n)} description" }
    date { (Time.now.utc - 60) }

    factory :event_future do
      date { Time.now.utc + 1.day }
    end

    factory :event_past do
      date { Time.now.utc - 1.day }
    end

    factory :owned_event do
      after(:create) do |event|
        create(
          :permission,
          item_type: "Event",
          item_id: event.id,
          bestowing_user: nil,
          user: create(:user_organiser),
          status: :owned
        )
      end
    end
  end
end
