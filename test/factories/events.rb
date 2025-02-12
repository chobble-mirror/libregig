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
      view_member { nil }
      edit_member { nil }
      band { nil }
    end

    after(:create) do |event, evaluator|
      if evaluator.owner
        create(
          :permission,
          item_type: "Event",
          item_id: event.id,
          bestowing_user: nil,
          user: evaluator.owner,
          status: :owned
        )
      end

      if evaluator.edit_member
        create(
          :permission,
          item_type: "Event",
          item_id: event.id,
          bestowing_user: nil,
          user: evaluator.edit_member,
          status: :accepted
        )
      end

      if evaluator.view_member
        create(
          :permission,
          item_type: "Event",
          item_id: event.id,
          bestowing_user: nil,
          user: evaluator.view_member,
          status: :accepted,
          permission_type: "view",
        )
      end

      if evaluator.band
        event.bands.delete_all
        event.bands << evaluator.band
      end
    end
  end
end
