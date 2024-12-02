require "test_helper"

class UserMailsControllerTest < ActionDispatch::IntegrationTest
  context "#index" do
    setup do
      UserMail.destroy_all
      @organiser_user = create(:user_organiser)
      @pending_mail = create(:user_mail, user: @organiser_user)
      @sending_mail = create(:user_mail_sending)
      @sent_mail_one = create(:user_mail_sent, user: @organiser_user)
      @sent_mail_two = create(:user_mail_sent)
      @failed_mail = create(:user_mail_failed, user: @organiser_user)
    end

    context "admin user" do
      setup do
        @user = create(:user_admin)
        log_in_as @user
      end

      should "list all user mails" do
        get user_mails_url

        assert_response :success

        mails = assigns(:mails)
        assert mails.present?
        assert_equal UserMail.all.sort_by(&:id), mails.sort_by(&:id)
        assert mails.include?(@sent_mail_one)
        assert mails.include?(@sent_mail_two)
        assert mails.include?(@pending_mail)
      end
    end

    context "organiser user" do
      setup do
        log_in_as @organiser_user
      end

      should "list mails only for current user" do
        get user_mails_url

        assert_response :success

        mails = assigns(:mails)
        assert mails.present?
        assert_equal UserMail.where(user_id: @organiser_user.id).sort_by(&:id), mails.sort_by(&:id)
        assert mails.include?(@sent_mail_one)
        refute mails.include?(@sent_mail_two)
        assert mails.include?(@pending_mail)
      end
    end

    context "member user" do
      setup do
        log_in_as create(:user_member)
      end

      should "not show any mails to member who has sent none" do
        get user_mails_url

        assert_response :success

        mails = assigns(:mails)
        assert mails.blank?
      end
    end
  end

  context "#show" do
    setup do
      @organiser_user = create(:user_organiser)
      @admin_user = create(:user_admin)
      @mail_one = create(:user_mail, user: @organiser_user)
      @mail_two = create(:user_mail, user: @admin_user)
    end

    context "admin user" do
      setup { log_in_as @admin_user }

      should "show mail from this user" do
        get user_mail_url(@mail_two)

        assert_response :success
        assert assigns(:mail)
      end

      should "show mail from another user" do
        get user_mail_url(@mail_one)

        assert_response :success
        assert assigns(:mail)
      end
    end

    context "organiser user" do
      setup { log_in_as @organiser_user }

      should "show mail from this user" do
        get user_mail_url(@mail_one)

        assert_response :success
        assert assigns(:mail)
      end

      should "not show mail from another user" do
        get user_mail_url(@mail_two)

        assert_redirected_to user_mails_path
        assert_equal "Cannot view this mail", flash[:alert]
      end
    end

    context "member user" do
      setup { log_in_as create(:user_member) }

      should "not show mail" do
        get user_mail_url(@mail_one)

        assert_redirected_to user_mails_path
        assert_equal "Cannot view this mail", flash[:alert]
      end
    end
  end

  context "#create" do
    setup do
      @organiser_user = create(:user_organiser)
      log_in_as @organiser_user
    end

    should "send confirmation registration email and redirect to index" do
      UserMailer.expects(:send_confirmation_registration).with(@organiser_user).returns(create(:user_mail))
      UserMail.any_instance.expects(:persisted?).returns(true)

      post user_mails_url

      assert_redirected_to user_mails_path
      assert_equal "Confirmation sent successfully", flash[:notice]
    end

    should "redirect to index with alert when mail fails to send" do
      UserMailer.expects(:send_confirmation_registration).with(@organiser_user).returns(create(:user_mail))
      UserMail.any_instance.expects(:persisted?).returns(false)

      post user_mails_url

      assert_redirected_to user_mails_path
      assert_equal "Failed to send confirmation", flash[:alert]
    end
  end
end
