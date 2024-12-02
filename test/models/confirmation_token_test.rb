require "test_helper"

class ConfirmationTokenTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
  end

  context "associations" do
    should belong_to(:user)
  end

  context "validations" do
    subject { build(:confirmation_token, user: create(:user)) }

    should validate_presence_of(:token)
    should validate_uniqueness_of(:token)
  end

  context "callbacks" do
    should "set expires_at before create" do
      token = @user.confirmation_tokens.create(token: SecureRandom.urlsafe_base64)
      assert_in_delta 24.hours.from_now, token.expires_at, 1.second
    end
  end

  context "scopes" do
    should "return only valid tokens" do
      freeze_time do
        valid_token = create(:confirmation_token, user: @user)
        expired_token = create(:confirmation_token,
          user: @user,
          expires_at: 1.second.ago)

        assert_includes ConfirmationToken.valid, valid_token
        refute_includes ConfirmationToken.valid, expired_token
      end
    end
  end

  context "token generation" do
    should "generate unique tokens" do
      token1 = create(:confirmation_token, user: @user)
      token2 = create(:confirmation_token, user: @user)

      refute_equal token1.token, token2.token
    end
  end

  context "expiration" do
    should "expire after 24 hours" do
      token = create(:confirmation_token, user: @user)

      travel 23.hours do
        assert ConfirmationToken.valid.include?(token)
      end

      travel 25.hours do
        refute ConfirmationToken.valid.include?(token)
      end
    end
  end
end
