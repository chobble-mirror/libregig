FactoryBot.define do
  factory :member, class: Member do
    sequence(:name) { |n| "member#{format("%05d", n)}" }
    sequence(:description) { |n| "this is test member #{format("%05d", n)}" }
    skills { [create(:skill)] }

    transient do
      owner { nil }
      edit_member { nil }
      view_member { nil }
    end

    after(:create) do |member, evaluator|
      def create_permission(
        member_id:,
        user:,
        status: :accepted,
        permission_type: "edit"
      )
        create(
          :permission,
          item_type: "Member",
          item_id: member_id,
          bestowing_user: nil,
          user:,
          status:,
          permission_type:
        )
      end

      if evaluator.owner
        create_permission(
          member_id: member.id,
          user: evaluator.owner,
          status: :owned
        )
      end

      if evaluator.edit_member
        create_permission(
          member_id: member.id,
          user: evaluator.edit_member
        )
      end

      if evaluator.view_member
        create_permission(
          member_id: member.id,
          user: evaluator.view_member,
          permission_type: "view"
        )
      end
    end

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
