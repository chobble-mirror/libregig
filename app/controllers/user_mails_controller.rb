class UserMailsController < ApplicationController
  before_action :set_mail, only: :show
  before_action :can_view_mail, only: :show

  def show
  end

  def index
    @mails =
      if Current.user.admin?
        UserMail.order(updated_at: :desc)
      else
        UserMail.where(user_id: Current.user.id).order(updated_at: :desc)
      end
  end

  def create
    @mail = UserMailer.send_confirmation_registration(Current.user)

    if @mail.persisted?
      redirect_to user_mails_path, notice: "Confirmation sent successfully"
    else
      redirect_to user_mails_path, alert: "Failed to send confirmation"
    end
  end

  private

  def set_mail
    @mail = UserMail.find(params[:id])
  end

  def can_view_mail
    return if @mail && (@mail.user_id == Current.user.id || Current.user.admin?)

    redirect_to user_mails_path, alert: "Cannot view this mail"
  end
end
