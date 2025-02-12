FactoryBot.define do
  factory :band, class: Band do |args|
    sequence(:name) { |n| "band#{format("%05d", n)}" }
    sequence(:description) { |n| "this is test band #{format("%05d", n)}" }

    transient do
      owner { nil }
      view_member { nil }
      band_member { nil }
    end

    after(:create) do |band, evaluator|
      if evaluator.owner
        create(
          :permission,
          item_type: "Band",
          item_id: band.id,
          bestowing_user: nil,
          user: evaluator.owner,
          status: :owned
        )
      end
      if evaluator.view_member
        create(
          :permission,
          item_type: "Band",
          item_id: band.id,
          bestowing_user: evaluator.owner, # maybe nil
          user: evaluator.view_member,
          permission_type: "view"
        )
      end

      if evaluator.band_member
        band.members.delete_all
        band.members << evaluator.band_member
      end
    end

    factory :band_with_members do
      after(:create) do |band|
        band.members.delete_all
        band.members << create(:member_with_user_with_edit_permission)
      end
    end
  end
end
