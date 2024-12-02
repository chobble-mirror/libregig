require "test_helper"

class PermissionTest < ActiveSupport::TestCase
  context "Validations" do
    setup do
      @organiser = create(:user_organiser)
      @admin = create(:user_admin)
      @member_one = create(:user_member)
      @member_two = create(:user_member)
      @event = create(:event)
    end

    should "have valid attributes for owned / invited permission" do
      owned_permission = build_permission(user: @organiser, bestowing_user: nil, status: :owned)
      assert_valid owned_permission
      owned_permission.save

      invited_permission = build_permission(user: @member_one, bestowing_user: @organiser, status: :pending)
      assert_valid invited_permission
    end

    should "only allow organisers to be bestowing_users" do
      permission = build_permission(bestowing_user: @member_one, user: @member_two)
      assert_not permission.valid?
      assert_includes permission.errors[:bestowing_user], "must be an organiser"
    end

    should "only allow members and organisers to be users" do
      permission = build_permission(user: @admin)
      assert_not permission.valid?
      assert_includes permission.errors[:user], "must be a member or organiser"
    end
  end

  private

  def build_permission(attributes = {})
    defaults = {
      item_type: "Event",
      item_id: @event.id,
      permission_type: "edit"
    }
    Permission.new(defaults.merge(attributes))
  end

  def assert_valid(record)
    assert record.valid?, error_messages(record)
  end

  def error_messages(record)
    "Errors: #{record.errors.full_messages.join(", ")}"
  end
end
