class Users::RegistrationController < ApplicationController
  before_action :set_user, only: %i[
    edit
    update
  ]

  def edit
  end

  def update
    UserMailer.send_confirmation_registration(@user) unless @user.confirmed?
  end

  def new
    @token = params[:token]
    verifier = Rails.application.config.message_verifier

    begin
      data = verifier.verify(@token)
      @user = User.find(data["user_id"])
      if @user.confirmed?
        redirect_to account_path,
          notice: "Your account is already confirmed"
      end

      if data["expires_at"]&.< Time.current.to_i
        flash[:alert] = "Your confirmation link has expired: #{data}."
        redirect_to register_path
      end
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      flash[:alert] = "Invalid confirmation link."
      redirect_to register_path
    end
  end

  def create
    token = params[:token]
    verifier = Rails.application.config.message_verifier

    begin
      data = verifier.verify(token)

      if data["expires_at"]&.>= Time.current.to_i
        @user = User.find(data["user_id"])
        @user.update(confirmed: true)
        flash[:notice] = "Your registration has been confirmed."
        redirect_to login_path
      else
        flash[:alert] = "Your confirmation link has expired: #{data}."
        redirect_to register_path
      end
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      flash[:alert] = "Invalid confirmation link."
      redirect_to register_path
    end
  end

  private

  def set_user
    @user = User.find(session[:user_id])
    redirect_to account_path if @user.confirmed?
  end
end
