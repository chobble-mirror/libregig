FactoryBot.define do
  factory :band, class: Band do
    sequence(:name) { |n| "band#{format("%05d", n)}" }
    sequence(:description) { |n| "this is test band #{format("%05d", n)}" }

    factory :band_with_members do
      after(:create) do |band|
        create(
          :permission,
          item_type: "Band",
          item_id: band.id,
          bestowing_user: nil,
          user: create(:user_organiser),
          status: :owned
        )
        band.members.delete_all
        band.members << create(:member_with_user_with_edit_permission)
      end
    end
  end
end
