class UserMailerPreview < ActionMailer::Preview
  def confirm_registration
    user = User.first
    UserMailer.confirm_registration(user)
  end
end
