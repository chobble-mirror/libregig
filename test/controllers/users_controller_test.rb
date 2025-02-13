require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  context "UsersController" do
    setup do
      @user = create(:user)
      @valid_user_params = {
        user: {
          username: "new_member_user",
          email: "new_user@example.com",
          password: "password",
          password_confirmation: "password",
          time_zone: "Europe/London",
          user_type: :member
        }
      }
    end

    context "#new" do
      should "display new user form when not logged in" do
        get register_path
        assert_response :success
        assert_select "form" do
          assert_select "input[name='user[username]']"
          assert_select "input[name='user[email]']"
          assert_select "input[name='user[password]']"
          assert_select "select[name='user[user_type]']"
        end
      end

      should "bounce to your profile if already logged in" do
        log_in_as(@user)
        get register_path
        assert_redirected_to account_path
      end
    end

    context "#edit" do
      should "get edit for current user" do
        log_in_as(@user)
        get account_path
        assert_response :success
      end

      should "redirect to login when not authenticated" do
        get account_path
        assert_redirected_to login_url
        assert_equal "You must be logged in", flash[:alert]
      end
    end

    context "#index" do
      should "not exist" do
        log_in_as(@user)
        get "/users"
        assert_response :not_found
      end
    end

    context "#create" do
      should "create user with valid parameters" do
        assert_difference("User.count", 1) do
          post register_path, params: @valid_user_params
        end
        assert_redirected_to account_path
        assert_equal "You registered successfully. Well done!", flash[:notice]
        user = assigns(:user)
        assert_equal user.id, session[:user_id]
        assert_not user.confirmed
      end

      should "not create user with invalid parameters" do
        invalid_params = @valid_user_params.deep_dup
        invalid_params[:user][:username] = ""
        assert_no_difference("User.count") do
          post register_path, params: invalid_params
        end
        assert_response :unprocessable_entity
      end

      should "allow creating admin user when no admin exists" do
        admin_params = @valid_user_params.deep_dup
        admin_params[:user][:user_type] = :admin
        assert_difference("User.count", 1) do
          post register_path, params: admin_params
        end
        assert_redirected_to account_path
        assert_equal "admin", assigns(:user).user_type
      end

      should "not allow creating admin user when admin already exists" do
        create(:user_admin)
        admin_params = @valid_user_params.deep_dup
        admin_params[:user][:user_type] = :admin
        assert_no_difference("User.count") do
          post register_path, params: admin_params
        end
        assert_response :unprocessable_entity
        assert_includes @response.body, "No more admin users allowed"
      end
    end

    context "#update" do
      should "update user with valid params" do
        log_in_as(@user)
        patch account_path, params: {user: {name: "New Name"}}
        assert_redirected_to account_path
        follow_redirect!
        @user.reload
        assert_equal "New Name", @user.name
        assert_includes @response.body, "Updated successfully"
      end

      should "not update user with missing email" do
        log_in_as(@user)
        patch account_path, params: {user: {email: ""}}
        assert_response :forbidden
        assert_equal "Could not update user: email can't be blank", response.body
      end

      should "not update user with invalid email" do
        log_in_as(@user)
        patch account_path, params: {user: {email: "wrong@"}}
        assert_response :forbidden
        assert_equal "Could not update user: email is invalid", response.body
      end

      should "not allow updating username" do
        log_in_as(@user)
        original_username = @user.username
        patch account_path, params: {user: {username: "new_username"}}
        @user.reload
        assert_equal original_username, @user.username
      end
    end
  end
end
