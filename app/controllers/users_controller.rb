class UsersController < ApplicationController
  before_action :check_admin_user, only: %i[
    create
    new
  ]

  before_action :check_not_logged_in, only: %i[
    create
    new
  ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(create_user_params)

    if @user.admin? && !@allow_admin_user
      flash.now[:alert] = "No more admin users allowed"
      return render :new, status: :unprocessable_entity
    end

    if @user.save
      session[:user_id] = @user.id
      redirect_to account_path, notice: "You registered successfully. Well done!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def index
    redirect_to user_path(Current.user)
  end

  def show
    @user = User.find_by(username: params[:id])
    redirect_to user_path(Current.user) unless @user
  end

  def edit
    @user = Current.user
    unless params[:id] == @user.username
      redirect_to user_path(@user), alert: "Can't edit other users"
    end
  end

  def update
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    @user = Current.user
    if @user.update(update_user_params)
      redirect_to user_url(@user), notice: "Updated successfully"
    else
      errors = @user.errors.full_messages.join(", ").downcase
      render plain: "Could not update user: #{errors}",
        status: :forbidden
    end
  end

  private

  def create_user_params
    params.require(:user).permit(
      :username,
      :name,
      :email,
      :password,
      :password_confirmation,
      :time_zone,
      :user_type
    )
  end

  def update_user_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :password_confirmation,
      :time_zone
    )
  end

  def check_admin_user
    @allow_admin_user = User.admin.count.zero?
  end

  def check_not_logged_in
    redirect_to account_path unless Current.user.nil?
  end
end
