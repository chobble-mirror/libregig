require "test_helper"

module Admin
  class ImpersonationControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = create(:user_admin)
      @target_user = create(:user)
      @impersonate_path = admin_impersonate_path
    end

    context "#create" do
      should "deny access if not admin" do
        log_in_as(@target_user)
        post @impersonate_path, params: {user_id: create(:user).id}
        assert_response :forbidden
      end

      should "set impersonation session if admin" do
        log_in_as(@admin)
        assert_nil session[:impersonation]

        post @impersonate_path, params: {user_id: @target_user.id}

        assert_redirected_to events_path
        assert_equal "Impersonating '#{@target_user.username}'", flash[:notice]

        assert_not_nil session[:impersonation]
        assert_equal @admin.id, session[:impersonation][:original_user_id]
        assert_equal @target_user.id, session[:impersonation][:target_user_id]
        assert_instance_of Time, session[:impersonation][:started_at]
      end

      should "set Current.user and Current.impersonator correctly" do
        log_in_as(@admin)
        post @impersonate_path, params: {user_id: @target_user.id}

        set_current_user

        assert_equal @target_user, Current.user
        assert_equal @admin, Current.impersonator
      end
    end

    context "#destroy" do
      context "with active impersonation" do
        setup do
          log_in_as(@admin)
          post @impersonate_path, params: {user_id: @target_user.id}
        end

        should "end impersonation and redirect with success notice" do
          assert_not_nil session[:impersonation]

          delete @impersonate_path
          assert_redirected_to admin_users_path
          assert_nil flash[:alert]
          assert_equal "Ended impersonation of #{@target_user.username}", flash[:notice]

          assert_nil session[:impersonation]
          assert_equal @admin.id, session[:user_id]
        end
      end

      context "without active impersonation" do
        setup do
          log_in_as(@admin)
        end

        should "redirect with alert message" do
          delete @impersonate_path

          assert_redirected_to admin_users_path
          assert_equal "No active impersonation session", flash[:alert]
        end
      end
    end

    private

    def set_current_user
      ApplicationController.new.send(:set_current_user_by_session, session)
    end
  end
end
