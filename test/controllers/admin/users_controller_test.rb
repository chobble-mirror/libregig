require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user_admin)
    @user = create(:user)
    log_in_as @admin
  end

  context "#index" do
    should "not be accessible to non-admins" do
      log_in_as(@user)
      get admin_users_url
      assert_response :forbidden
      assert_equal "Admins only", @response.body
    end

    should "get index" do
      get admin_users_url
      assert_response :success
      assert_not_nil assigns(:users)
    end

    should "filter users by type" do
      other_user_type = User.user_types.keys.compact_blank.sample.to_s
      create_list(:user, 3, user_type: other_user_type)

      expected_count = User.where(user_type: other_user_type).count

      get admin_users_url, params: {user_type: other_user_type}

      assert_response :success
      assert_equal expected_count, assigns(:users).count
      assert assigns(:users).all? { |user| user.user_type == other_user_type }
    end

    should "redirect if user type param is invalid" do
      get admin_users_url, params: {user_type: "invalid"}
      assert_redirected_to admin_users_url
      assert_includes "Invalid user type", @response.body
    end
  end

  context "#new" do
    should "get new" do
      get new_admin_user_url
      assert_response :success
      assert assigns(:numbers)
    end
  end

  context "#create" do
    should "create users, bands, events" do
      post admin_users_url, params: {
        admin_add_fake_users_form: {
          members: "10",
          bands: "5",
          events: "2"
        }
      }
      assert_response :redirect
      follow_redirect!
      assert_response :success
      assert_match(/Members: 10/, flash[:notice])
      assert_match(/Bands: 5/, flash[:notice])
      assert_match(/Events: 2/, flash[:notice])
    end

    should "handle invalid parameters" do
      post admin_users_url, params: {admin_add_fake_users_form: {members: "abc"}}
      assert_response :redirect
      follow_redirect!
      assert_response :success
      assert_match(/Invalid/, flash[:alert])
    end
  end

  context "#show" do
    should "get show" do
      get admin_user_url(@user.username)
      assert_response :success
      assert assigns(:user)
    end
  end

  context "#edit" do
    should "get edit" do
      get edit_admin_user_url(@user.username)
      assert_response :success
      assert assigns(:user)
    end
  end

  context "#update" do
    setup do
      @update_params = {name: "New Name", email: "new@example.com"}
    end

    should "update user" do
      patch admin_user_url(@user.username), params: {
        user: {
          name: "New Name",
          email: "new@example.com"
        }
      }
      assert_response :redirect
      follow_redirect!
      assert_response :success
      assert_equal "User updated", flash[:notice]
      @user.reload
      assert_equal "New Name", @user.name
      assert_equal "new@example.com", @user.email
    end

    should "not update user with invalid data" do
      patch admin_user_url(@user.username), params: {
        user: {
          name: "New Name",
          email: "invalid"
        }
      }
      assert_response :unprocessable_entity
      @user.reload
      assert_not_equal "invalid", @user.email
    end

    should "not allow duplicate username" do
      other_user = create(:user)
      assert_not_equal other_user.username, @user.username
      patch admin_user_url(@user.username), params: {
        username: other_user.username
      }
      assert_response :bad_request
      @user.reload
      assert_not_equal other_user.username, @user.username
    end
  end

  context "#destroy" do
    should "destroy user" do
      delete admin_user_url(@user.username)
      assert_response :redirect
      follow_redirect!
      assert_response :success
      assert_equal "User deleted.", flash[:notice]
      assert_nil User.find_by(username: @user.username)
    end
  end
end
