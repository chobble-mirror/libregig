require "test_helper"

class PermissionsHelperTest < ActionView::TestCase
  include PermissionsHelper

  context "#get_access_level - members" do
    should "return :edit if user owns a member" do
      user_organiser = create(:user_organiser)
      member = create(:member, owner: user_organiser)
      access_level = get_ownership_member(
        user_organiser,
        member
      )
      assert_equal "edit", access_level
    end

    should "return :edit if user has edit access to a member" do
      user_organiser = create(:user_organiser)
      user_member = create(:user_member)
      member = create(
        :member,
        owner: user_organiser,
        edit_member: user_member
      )
      access_level = get_ownership_member(
        user_member,
        member
      )
      assert_equal "edit", access_level
    end

    should "return :view if user has view access to a member" do
      user_organiser = create(:user_organiser)
      user_member = create(:user_member)
      member = create(
        :member,
        owner: user_organiser,
        view_member: user_member
      )
      access_level = get_access_level(
        user_member,
        member
      )
      assert_equal "view", access_level
    end

    should "count permissions properly" do
      user_organiser = create(:user_organiser)
      user_member = create(:user_member)

      create(
        :member,
        owner: user_organiser,
        view_member: user_member
      )

      other_owner = create(:user_organiser)
      other_member = create(:user_member)
      create(
        :member,
        owner: other_owner,
        view_member: other_member,
      )

      assert_equal 1, user_organiser.members.to_a.count
      assert_equal 1, user_member.members.to_a.count
    end

    should "return view if user has access to a band containing this member" do
      user_organiser = create(:user_organiser)
      user_member = create(:user_member)
      member = create(
        :member,
        owner: user_organiser
      )
      band = create(
        :band,
        owner: user_organiser,
        view_member: user_member,
        band_member: member
      )
      access_level = get_ownership_member(
        user_member,
        member
      )
      assert_equal "view", access_level
    end

    should "return view if user has access to an event containing a band containing this member" do
      user_member = create(:user_member)

      band = create(:band)
      member = create(:member)
      band.members << member

      event = create(:event, view_member: user_member)
      event.bands << band

      access_level = get_ownership_member(user_member, member)
      assert_equal "view", access_level
    end

    should "return view if user has access to a band member that shares a band with this one" do
      user_member = create(:user_member)

      band = create(:band)
      member = create(:member, edit_member: user_member)
      band.members << member

      other_member = create(:member)
      band.members << member

      access_level = get_ownership_member(user_member, member)
      assert_equal "edit", access_level

      access_level = get_ownership_member(user_member, other_member)
      assert_equal "view", access_level
    end
  end
end
