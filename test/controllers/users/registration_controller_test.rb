require "test_helper"

class Users::RegistrationControllerTest < ActionDispatch::IntegrationTest
  context "#new" do
    context "token is valid" do
      context "user is confirmed" do
        setup do
          @user = create(:user)
          ActiveSupport::MessageVerifier.any_instance
            .expects(:verify)
            .returns({"user_id" => @user.id})
        end

        should "redirect to edit user path" do
          get confirm_registration_url({"token" => 16762826})

          assert_response :redirect
          assert_redirected_to account_path
        end
      end

      context "user is not confirmed" do
        setup do
          @user = create(:user_unconfirmed)
        end

        context "if token is expired" do
          setup do
            @params = {
              "user_id" => @user.id,
              "expires_at" => (Time.now.utc - 1.minute).to_i
            }
            ActiveSupport::MessageVerifier.any_instance
              .expects(:verify)
              .returns(@params)
          end

          should "redirect to register path with error" do
            get confirm_registration_url({"token" => 16762826})

            assert_response :redirect
            assert_redirected_to register_path
            assert_equal(
              "Your confirmation link has expired: #{@params.inspect}.",
              flash[:alert]
            )
          end
        end

        context "id token is not expired" do
          setup do
            ActiveSupport::MessageVerifier.any_instance
              .expects(:verify)
              .returns({"user_id" => @user.id})
          end

          should "succeed" do
            get confirm_registration_url({"token" => 16762826})

            assert_response :success
          end
        end
      end
    end

    context "token is invalid" do
      setup do
        ActiveSupport::MessageVerifier.any_instance
          .expects(:verify)
          .raises(ActiveSupport::MessageVerifier::InvalidSignature.new(
            "bad token"
          ))
      end

      should "redirect to register path with error" do
        get confirm_registration_url({"token" => 16762826})

        assert_response :redirect
        assert_redirected_to register_path
        assert_equal "Invalid confirmation link.", flash[:alert]
      end
    end
  end

  context "#create" do
    setup do
      @user = create(:user_unconfirmed)
    end

    context "token is valid" do
      setup do
        ActiveSupport::MessageVerifier.any_instance
          .expects(:verify)
          .returns({
            "user_id" => @user.id,
            "expires_at" => (Time.now.utc + 1.day).to_i
          })
      end

      should "update user to confirmed and redirect to login with success" do
        refute @user.confirmed?

        post confirm_registration_submit_url({"token" => 16762826})

        assert_response :redirect
        assert_redirected_to login_path
        assert_equal(
          "Your registration has been confirmed.",
          flash[:notice]
        )

        @user.reload
        assert @user.confirmed?
      end
    end

    context "if token is expired" do
      setup do
        @params = {
          "user_id" => @user.id,
          "expires_at" => (Time.now.utc - 1.minute).to_i
        }
        ActiveSupport::MessageVerifier.any_instance
          .expects(:verify)
          .returns(@params)
      end

      should "redirect to register path with error" do
        post confirm_registration_submit_url({"token" => 16762826})

        assert_redirected_to register_path
        assert_equal(
          "Your confirmation link has expired: #{@params.inspect}.",
          flash[:alert]
        )
      end
    end

    context "token is invalid" do
      setup do
        ActiveSupport::MessageVerifier.any_instance
          .expects(:verify)
          .raises(ActiveSupport::MessageVerifier::InvalidSignature.new(
            "bad token"
          ))
      end

      should "redirect to register path with error" do
        post confirm_registration_submit_url({"token" => 16762826})

        assert_response :redirect
        assert_redirected_to register_path
        assert_equal "Invalid confirmation link.", flash[:alert]
      end
    end
  end

  context "#update" do
    context "user is unconfirmed" do
      setup do
        @user = create(:user_unconfirmed)
      end

      should "send user confirmation email" do
        User.expects(:find).returns(@user)
        UserMailer.expects(:send_confirmation_registration)
          .with(@user)
          .returns(instance_of(UserMail))

        post resend_confirmation_url

        assert_response :success
      end
    end

    context "user is confirmed already" do
      setup do
        @user = create(:user)
      end

      should "not send confirmation email and redirect to user edit" do
        User.expects(:find).returns(@user)
        UserMailer.expects(:confirm_registration).never

        post resend_confirmation_url

        assert_response :redirect
        assert_redirected_to account_path
      end
    end
  end
end
