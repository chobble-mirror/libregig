require "test_helper"

class MemberTest < ActiveSupport::TestCase
  should have_many :band_members
  should have_many :bands

  should have_many :member_skills
  should have_many :skills

  context "validations" do
    setup { @member_one = create(:member_with_user_with_edit_permission) }

    should "be valid with valid attributes" do
      assert @member_one.valid?
    end
  end

  context "Member audits" do
    setup do
      @user = create(:user)
      @member = create(:member, name: "Original Name")
      Current.user = @user
    end

    should "create audit log entry for changed columns" do
      assert_difference("MembersAudit.count") do
        @member.update!(name: "Updated Name")
      end

      audit = MembersAudit.last
      assert_equal @member.id, audit.member_id
      assert_equal "name", audit.column_changed
      assert_equal "Original Name", audit.old_value
      assert_equal "Updated Name", @member.name
      assert_equal @user.id, audit.user_id
    end

    should "not log unchanged columns" do
      assert_no_difference("MembersAudit.count") do
        @member.update!(name: "Original Name")
      end
    end
  end
end
