require "test_helper"

class UserMailTest < ActiveSupport::TestCase
  should belong_to :user

  should validate_presence_of :subject
  should validate_length_of(:subject).is_at_most(120)

  should validate_presence_of :recipient
  should validate_length_of(:recipient).is_at_most(255)

  should validate_presence_of :template
  should validate_length_of(:template).is_at_most(50)

  should validate_presence_of :params

  context "#html_content" do
    setup do
      params = {username: "Steve McSteverson", url: "https://moo.com"}
      @user_mail = create(:user_mail, params:)
      @expected_content = "<!DOCTYPE html>\n<html>\n<head>\n  <meta charset=\"UTF-8\">\n</head>\n<body>\n" \
        "<p>\n  Hi Steve McSteverson\n</p>\n<p>\n  To confirm your registration, click here:\n</p>\n" \
        "<p>\n  <a href=\"https://moo.com\">https://moo.com</a>\n</p>\n</body>\n</html>\n"
    end

    should "render template and params as html" do
      assert_equal @expected_content, @user_mail.html_content
    end
  end

  context "#text_content" do
    setup do
      params = {username: "Steve McSteverson", url: "https://moo.com"}
      @user_mail = create(:user_mail, params:)
      @expected_content = "Hi Steve McSteverson\n\n" \
        "To confirm your registration, click here:\n\n" \
        "https://moo.com\n"
    end

    should "render template and params as text" do
      assert_equal @expected_content, @user_mail.text_content
    end
  end

  context "#attempt_send" do
    setup do
      @user_mail = create(:user_mail)
    end

    should "return if user mail is not pending" do
      user_mail_sending = create(:user_mail_sending)

      UserMailer.expects(:confirm_registration).never

      user_mail_sending.attempt_send

      assert_equal "sending", user_mail_sending.state
    end

    context "when the email sends" do
      should "deliver confirm registration email and set state to sent" do
        UserMailer.expects(:confirm_registration).returns(Mail::Message.new)
        Mail::Message.any_instance.expects(:deliver_now)

        @user_mail.attempt_send
        @user_mail.reload

        assert_equal "sent", @user_mail.state
      end
    end

    context "when sending fails" do
      should "update state to failed" do
        UserMailer.expects(:confirm_registration).raises(StandardError.new("RUNTIME ERROR MESSAGE"))

        @user_mail.attempt_send
        @user_mail.reload

        assert_equal "failed", @user_mail.state
      end
    end
  end
end
