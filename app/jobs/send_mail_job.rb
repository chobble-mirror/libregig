class SendMailJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: 1.minute, attempts: 5

  def perform(user_mail_id)
    user_mail = UserMail.find(user_mail_id)
    user_mail.attempt_send
  end
end
