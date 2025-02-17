require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user_member)
  end

  context "#new" do
    should "get new" do
      get login_url
      assert_response :success
      assert assigns(:user)
    end

    should "redirect to events when user signed in" do
      user = create(:user)
      log_in_as user

      get login_url
      assert_redirected_to events_path
    end
  end

  context "#create" do
    setup do
      @params = {
        user: {
          username: @user.username,
          password: "password"
        }
      }
    end

    should "create session" do
      post login_url, params: @params

      assert_redirected_to events_path # should redirect upon successful login
      assert_equal @user.id, session[:user_id]

      follow_redirect!
      assert_response :success # verify that the redirect was successful
    end

    should "not create session if authentication fails" do
      User.any_instance.expects(:authenticate).returns(false)

      post login_url, params: @params

      assert_response :unprocessable_entity
      assert_template :new
      assert_equal "Invalid username or password", flash[:alert]
      assert_nil session[:user_id]
    end

    should "skip login in development mode" do
      Rails.env = "development"
      post login_url, params: {
        user: {
          username: @user.username,
          debug_skip: true
        }
      }
      Rails.env = "test"

      assert_redirected_to events_path # should redirect upon successful login
      assert_equal @user.id, session[:user_id]

      follow_redirect!
      assert_response :success # verify that the redirect was successful
    end

    should "not skip login when not in development mode" do
      assert_not Rails.env.development?

      post login_url, params: {
        user: {
          username: @user.username,
          debug_skip: true
        }
      }

      assert_response :unprocessable_entity
      assert_template :new
      assert_equal "Invalid username or password", flash[:alert]
      assert_nil session[:user_id]
    end
  end

  context "#destroy" do
    setup do
      post login_url, params: {username: @user.username, password: "password"}
    end

    should "destroy session" do
      delete logout_url
      assert_nil session[:user_id]

      assert_response :redirect
      follow_redirect!
      assert_response :success
    end
  end
end
