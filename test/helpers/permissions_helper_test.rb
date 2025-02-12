require "test_helper"

class PermissionsHelperTest < ActionView::TestCase
  include PermissionsHelper

  context "#get_access_level" do
    should "member: return :edit if user owns a member" do
      user_organiser = create(:user_organiser)
      member = create(:member, owner: user_organiser)

      access_level = get_access_level(user_organiser, member)
      assert_equal "edit", access_level
    end

    should "member: return :edit if user has edit access to a member" do
      user_organiser = create(:user_organiser)
      user_member = create(:user_member)
      member = create(:member, owner: user_organiser, edit_member: user_member)

      access_level = get_access_level(user_member, member)
      assert_equal "edit", access_level
    end

    should "member: return :view if user has view access to a member" do
      user_organiser = create(:user_organiser)
      user_member = create(:user_member)
      member = create(:member, owner: user_organiser, view_member: user_member)

      access_level = get_access_level(user_member, member)
      assert_equal "view", access_level
    end

    should "member: count permissions properly" do
      user_organiser = create(:user_organiser)
      user_member = create(:user_member)

      create(:member, owner: user_organiser, view_member: user_member)

      other_owner = create(:user_organiser)
      other_member = create(:user_member)
      create(:member, owner: other_owner, view_member: other_member)

      assert_equal 1, user_organiser.members.to_a.count
      assert_equal 1, user_member.members.to_a.count
    end

    should "member:  can view if user has access to a band containing this member" do
      user_organiser = create(:user_organiser)
      user_member = create(:user_member)
      member = create(:member, owner: user_organiser)
      band = create(
        :band,
        owner: user_organiser,
        view_member: user_member,
        band_member: member
      )
      access_level = get_access_level(user_member, member)
      assert_equal "view", access_level
    end

    should "member:  can view if user has access to an event containing a band containing this member" do
      user_member = create(:user_member)

      band = create(:band)
      member = create(:member)
      band.members << member

      event = create(:event, view_member: user_member)
      event.bands << band

      access_level = get_access_level(user_member, member)
      assert_equal "view", access_level
    end

    should "member:  can view if user has access to a band member that shares a band with this one" do
      user_member = create(:user_member)

      band = create(:band)
      member = create(:member, edit_member: user_member)
      band.members << member

      other_member = create(:member)
      band.members << other_member

      access_level = get_access_level(user_member, other_member)
      assert_equal "view", access_level
    end

    should "member: return nil if user does not have access to a band member that shares a band with this one" do
      user_member = create(:user_member)

      band = create(:band)
      member = create(:member, edit_member: user_member)
      band.members << member

      other_member = create(:member)
      band_two = create(:band)
      band_two.members << other_member

      access_level = get_access_level(user_member, other_member)
      assert_nil access_level
    end

    should "member:  can view if user has access to a band member that shares an event with this one" do
      user_member = create(:user_member)

      band_one = create(:band)
      my_member = create(:member, edit_member: user_member)
      band_one.members << my_member

      other_member = create(:member)
      band_two = create(:band)
      band_two.members << other_member

      event = create(:event)
      event.bands << band_one
      event.bands << band_two

      access_level = get_access_level(user_member, other_member)
      assert_equal "view", access_level
    end

    should "band: return :edit if user owns a band" do
      user_organiser = create(:user_organiser)
      band = create(:band, owner: user_organiser)

      access_level = get_access_level(user_organiser, band)
      assert_equal "edit", access_level
    end

    should "band: return :edit if user has edit access to a band" do
      user_member = create(:user_member)
      band = create(:band, edit_member: user_member)

      access_level = get_access_level(user_member, band)
      assert_equal "edit", access_level
    end

    should "band: return :view if user has view access to a band" do
      user_member = create(:user_member)
      band = create(:band, view_member: user_member)

      access_level = get_access_level(user_member, band)
      assert_equal "view", access_level
    end

    should "band:  can view if user has a member in this band" do
      user_member = create(:user_member)
      member = create(:member, view_member: user_member)
      band = create(:band, band_member: member)
      access_level = get_access_level(user_member, band)
      assert_equal "view", access_level
    end

    should "band: can view if user has an event ft this band" do
      user_member = create(:user_member)
      band = create(:band)
      event = create(:event, view_member: user_member)
      event.bands << band
      access_level = get_access_level(user_member, band)
      assert_equal "view", access_level
    end

    should "band: can view if user has a band on a bill with this band" do
      band = create(:band)
      event = create(:event)
      event.bands << band

      user_member = create(:user_member)
      member_band = create(:band, view_member: user_member)
      event.bands << member_band

      access_level = get_access_level(user_member, band)
      assert_equal "view", access_level
    end

    should "event: return :edit if user owns a event" do
      user_organiser = create(:user_organiser)
      event = create(:event, owner: user_organiser)

      access_level = get_access_level(user_organiser, event)
      assert_equal "edit", access_level
    end

    should "event: return :edit if user has edit access to a event" do
      user_member = create(:user_member)
      event = create(:event, edit_member: user_member)

      access_level = get_access_level(user_member, event)
      assert_equal "edit", access_level
    end

    should "event: return :view if user has view access to a event" do
      user_member = create(:user_member)
      event = create(:event, view_member: user_member)

      access_level = get_access_level(user_member, event)
      assert_equal "view", access_level
    end

    should "event: return :view if user has view access to a band at the event" do
      user_member = create(:user_member)
      event = create(:event)
      band = create(:band, view_member: user_member)
      event.bands << band

      access_level = get_access_level(user_member, event)
      assert_equal "view", access_level
    end

    should "event: return :view if user has view access to a member in a band at the event" do
      user_member = create(:user_member)
      event = create(:event)
      member = create(:member, view_member: user_member)
      band = create(:band)
      band.members << member
      event.bands << band

      access_level = get_access_level(user_member, event)
      assert_equal "view", access_level
    end
  end
end
