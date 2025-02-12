FactoryBot.define do
  factory :event, class: Event do
    sequence(:name) { |n| "Event #{format("%05d", n)}" }
    sequence(:description) { |n| "Event #{format("%05d", n)} description" }
    start_date { (Time.now.utc - 60) }
    end_date { (Time.now.utc - 60) }

    factory :event_future do
      start_date { Time.now.utc + 1.day }
      end_date { Time.now.utc + 1.day }
    end

    factory :event_past do
      start_date { Time.now.utc - 1.day }
      end_date { Time.now.utc - 1.day }
    end

    transient do
      owner { nil }
    end

    after(:create) do |event, evaluator|
      create(
        :permission,
        item_type: "Event",
        item_id: event.id,
        bestowing_user: nil,
        user: evaluator.owner || create(:user_organiser),
        status: :owned
      )
    end
  end
end
