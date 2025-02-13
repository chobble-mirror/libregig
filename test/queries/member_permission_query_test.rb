require "test_helper"

class MemberPermissionQueryTest < ActiveSupport::TestCase
  context "shares_band_with_permitted_member_sql" do
    setup do
      @user = create(:user)
      @band = create(:band)

      # Member the user has direct permission to
      @permitted_member = create(:member, edit_member: @user)

      # Member in same band as permitted member
      @same_band_member = create(:member)

      # Add both members to the same band
      @band.members << @permitted_member
      @band.members << @same_band_member

      # Member in a different band (should not be visible)
      @other_band = create(:band)
      @different_band_member = create(:member)
      @other_band.members << @different_band_member
    end

    should "find members in same band" do
      sql =
        MemberPermissionQuery.shares_band_with_permitted_member_sql(@user.id)
      members = Member.where(id: Member.find_by_sql(sql))

      assert_includes members, @same_band_member
      assert_not_includes members, @different_band_member
    end

    should "handle multiple bands" do
      # Add permitted member to another band
      another_band = create(:band)
      another_member = create(:member)
      another_band.members << @permitted_member
      another_band.members << another_member

      sql =
        MemberPermissionQuery.shares_band_with_permitted_member_sql(@user.id)
      members = Member.where(id: Member.find_by_sql(sql))

      assert_includes members, @same_band_member
      assert_includes members, another_member
      assert_not_includes members, @different_band_member
    end

    should "handle user with multiple permitted members" do
      another_permitted_member = create(:member, edit_member: @user)
      yet_another_band = create(:band)
      band_member = create(:member)
      yet_another_band.members << another_permitted_member
      yet_another_band.members << band_member

      sql =
        MemberPermissionQuery.shares_band_with_permitted_member_sql(@user.id)
      members = Member.where(id: Member.find_by_sql(sql))

      assert_includes members, @same_band_member
      assert_includes members, band_member
      assert_not_includes members, @different_band_member
    end

    should "not return duplicates" do
      # Add same_band_member to another band with permitted member
      another_band = create(:band)
      another_band.members << @permitted_member
      another_band.members << @same_band_member

      sql =
        MemberPermissionQuery.shares_band_with_permitted_member_sql(@user.id)
      members = Member.where(id: Member.find_by_sql(sql))

      assert_equal 1, members.where(id: @same_band_member.id).count
    end

    should "handle empty bands" do
      empty_band = create(:band)

      sql =
        MemberPermissionQuery.shares_band_with_permitted_member_sql(@user.id)
      members = Member.where(id: Member.find_by_sql(sql))

      assert_includes members, @same_band_member
    end
  end
end
