FactoryBot.define do
  factory :member, class: Member do
    sequence(:name) { |n| "member#{format("%05d", n)}" }
    sequence(:description) { |n| "this is test member #{format("%05d", n)}" }
    skills { [create(:skill)] }

    factory :member_with_user_with_edit_permission do
      after(:create) do |member|
        create(
          :permission,
          item_type: "Member",
          item_id: member.id,
          bestowing_user: nil,
          user: create(:user_organiser),
          status: :owned
        )
      end
    end
  end
end
