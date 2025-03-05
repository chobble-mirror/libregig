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
        assert_redirected_to user_path(@user)
      end

      should "redirect to login when not authenticated" do
        get account_path
        assert_redirected_to login_url
        assert_equal "You must be logged in", flash[:alert]
      end
    end

    context "#index" do
      should "redirect to current user's profile when logged in" do
        log_in_as(@user)
        get "/users"
        assert_redirected_to user_path(@user)
      end

      should "redirect to login when not authenticated" do
        get "/users"
        assert_redirected_to login_url
      end
    end

    context "#show" do
      should "show user's own profile when authenticated" do
        log_in_as(@user)
        get user_path(@user)
        assert_response :success
        assert_equal @user, assigns(:user)
      end

      should "allow viewing another user's profile" do
        other_user = create(:user)
        log_in_as(@user)
        get user_path(other_user)
        assert_response :success
        assert_equal other_user, assigns(:user)
      end

      should "redirect to login when not authenticated" do
        get user_path(@user)
        assert_redirected_to login_url
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
        assert_redirected_to user_url(@user)
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

      should "update password when provided" do
        log_in_as(@user)
        patch account_path, params: {user: {
          password: "newpassword",
          password_confirmation: "newpassword"
        }}
        assert_redirected_to user_url(@user)
        follow_redirect!
        @user.reload
        assert @user.authenticate("newpassword")
      end

      should "skip password update when blank" do
        log_in_as(@user)
        original_password_digest = @user.password_digest
        patch account_path, params: {user: {
          name: "New Name",
          password: "",
          password_confirmation: ""
        }}
        assert_redirected_to user_url(@user)
        @user.reload
        assert_equal original_password_digest, @user.password_digest
      end

      should "not allow updating differnet user" do
        log_in_as(@user)
        other_user = create(:user)
        original_other_email = other_user.email
        params = {user: {email: "newemail@example.com"}}
        patch user_path other_user, params: params
        assert_redirected_to user_url(@user)
        other_user.reload
        assert_equal other_user.email, original_other_email
      end

      should "require authentication" do
        patch account_path, params: {user: {name: "New Name"}}
        assert_redirected_to login_url
      end
    end
  end
end
