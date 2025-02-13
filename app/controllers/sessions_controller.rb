class SessionsController < ApplicationController
  def new
    redirect_to events_path if Current.user
    @user = User.new
  end

  def create
    username, password = login_params.values_at(:username, :password)
    logger.debug("Login attempt from #{username}")
    user = User.find_or_create_by(username: username)

    if Rails.env == "development" && params.dig(:user, :debug_skip)
      session[:user_id] = user.id
      logger.debug("Skipped login: #{username}")
      redirect_to events_path, notice: "Skipped login."
    elsif user.authenticate(password)
      session[:user_id] = user.id
      logger.debug("Login success: #{username}")
      redirect_to events_path, notice: "Logged in successfully."
    else
      @user = User.new
      @user.username = username
      logger.debug "Login failed: #{user.inspect}"
      flash[:alert] = "Invalid username or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    session[:impersonation] = nil
    redirect_to login_path, notice: "Logged out successfully."
  end

  private

  def login_params
    params.require(:user).permit(:username, :password)
  end
end
