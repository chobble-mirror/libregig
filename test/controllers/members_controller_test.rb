require "test_helper"

class MembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @member = create(:member_with_user_with_edit_permission)
    @user = @member.owner
    log_in_as @user
  end

  context "#index" do
    should "get index" do
      get members_url
      assert_response :success
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

      assert_redirected_to member_url(Member.last)
    end

    should "render new member form if save fails" do
      Member.any_instance.expects(:save).returns(false)

      assert_no_difference "Member.count" do
        post members_url,
          params: {
            member: {
              name: "John Doe",
              description: "New member description",
              user_id: @user.id
            }
          }
      end

      assert_response :unprocessable_entity
      assert_template :new
    end
  end

  context "#update" do
    should "update member and redirect" do
      patch member_url(@member), params: {member: {name: "Updated Name"}}
      assert_redirected_to member_url(@member)
    end

    should "render edit form if update fails " do
      Member.any_instance.expects(:update).returns(false)

      patch member_url(@member), params: {member: {name: "Updated Name"}}

      assert_response :unprocessable_entity
      assert_template :edit
    end
  end

  context "#destroy" do
    should "destroy member" do
      assert_difference("Member.count", -1) do
        delete member_url(@member)
      end

      assert_redirected_to members_url
    end
  end
end
