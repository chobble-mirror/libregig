require "test_helper"

class MembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_member = create(:user_member)
    @user_organiser = create(:user_organiser)
    @member = create(:member, owner: @user_organiser, view_member: @user_member)
    @band = create(:band)

    @unrelated_member = create(:member)
    @member_in_same_band = create(:member)

    @band.members << @member
    @band.members << @member_in_same_band

    log_in_as @user_member
  end

  context "#index" do
    should "get index" do
      get members_url
      assert_response :success
      members = assigns(:members)
      assert_includes members, @member
      assert_includes members, @member_in_same_band
      assert_not_includes members, @unrelated_member
    end
  end

  context "#new" do
    should "get new" do
      get new_member_url
      assert_response :success
    end
  end

  context "#show" do
    should "show member" do
      get member_url(@member)
      assert_response :success
      assert_select "section.skills h2", "Skills:"
      assert_select "section.skills ul" do |elements|
        elements.each do |element|
          assert_select element, "li", @member.skills.first.name
        end
      end
    end
  end

  context "#edit" do
    should "get edit" do
      log_in_as @user_organiser
      get edit_member_url(@member)
      assert_response :success
    end
  end

  context "#create" do
    should "create member and redirect" do
      assert_difference "Member.count" do
        post members_url,
          params: {
            member: {
              name: "John Doe",
              description: "New member description"
            }
          }
      end

      assert_response :redirect
      member = assigns(:member)
      assert_equal "John Doe", member.name
    end

    should "render new member form if save fails" do
      Member.any_instance.expects(:save).returns(false)

      assert_no_difference "Member.count" do
        post members_url,
          params: {
            member: {
              name: "John Doe",
              description: "New member description",
              user_id: @user_member.id
            }
          }
      end

      assert_response :unprocessable_entity
      assert_template :new
    end
  end

  context "#update" do
    should "update member and redirect" do
      log_in_as @user_organiser
      patch member_url(@member), params: {member: {name: "Updated Name"}}
      assert_redirected_to member_url(@member)
    end

    should "deny member organiser" do
      log_in_as @user_member
      patch member_url(@member), params: {member: {name: "Updated Name"}}
      assert_response :not_found
    end

    should "render edit form if update fails " do
      log_in_as @user_organiser
      Member.any_instance.expects(:save).returns(false)
      patch member_url(@member), params: {member: {name: "Updated Name"}}

      assert_response :unprocessable_entity
      assert_template :edit
    end
  end

  context "#destroy" do
    should "destroy member" do
      log_in_as @user_organiser
      assert_difference("Member.count", -1) do
        delete member_url(@member)
      end
      assert_redirected_to members_url
    end

    should "deny destroy to view-only member" do
      log_in_as @user_member
      assert_difference("Member.count", 0) do
        delete member_url(@member)
      end
      assert_response :not_found
    end
  end
end
