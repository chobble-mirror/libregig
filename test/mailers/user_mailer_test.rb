require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  context "UserMailer" do
    setup do
      @user = create(:user)
      @confirmation_token = @user.confirmation_tokens.create!(token: "test_token")
      @confirmation_url = "http://example.com/confirm_registration?token=test_token"
    end

    context ".send_confirmation_registration" do
      should "create UserMail and enqueue SendMailJob" do
        assert_difference "UserMail.count", 1 do
          assert_enqueued_with(job: SendMailJob) do
            @user_mail = UserMailer.send_confirmation_registration(@user)
          end
        end

        assert_equal @user, @user_mail.user
        assert_equal @user.email, @user_mail.recipient
        assert_equal UserMailer::CONFIRM_REGISTRATION_SUBJECT, @user_mail.subject
        assert_equal "confirm_registration", @user_mail.template
        assert_equal @user.username, @user_mail.params["username"]
        assert_match(/confirm_registration\?token=/, @user_mail.params["url"])
      end
    end

    context ".confirm_registration" do
      setup do
        @user_mail = create_user_mail
        @email = UserMailer.confirm_registration(@user_mail)
      end

      should "generate correct email" do
        assert_emails 1 do
          @email.deliver_now
        end

        assert_equal [@user_mail.recipient], @email.to
        assert_equal UserMailer::CONFIRM_REGISTRATION_SUBJECT, @email.subject
        assert_email_parts(@email, @user.username)
        assert_email_parts(@email, @confirmation_url)
      end
    end

    context ".generate_confirmation_url" do
      should "return correct URL" do
        expected_url = "http://test.host/confirm_registration?token=test_token"
        Rails.configuration.server_url = "http://test.host"

        assert_equal expected_url, UserMailer.generate_confirmation_url(@confirmation_token)
      end
    end
  end

  private

  def create_user_mail
    UserMail.new(
      user: @user,
      recipient: @user.email,
      subject: UserMailer::CONFIRM_REGISTRATION_SUBJECT,
      template: "confirm_registration",
      params: {
        username: @user.username,
        url: @confirmation_url
      }
    )
  end

  def assert_email_parts(email, content)
    [email.html_part, email.text_part].each do |part|
      assert_includes part.body.to_s, content
    end
  end
end
