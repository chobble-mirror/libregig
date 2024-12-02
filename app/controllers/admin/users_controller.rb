module Admin
  class UsersController < AdminController
    before_action :set_user, except: %i[
      create
      index
      new
    ]

    def index
      @user_type = params[:user_type]&.to_sym

      if @user_type && !User.user_types[@user_type]
        flash[:alert] = "Invalid user type"
        redirect_to admin_users_path
      end

      @user_types = User.user_types.keys

      @users =
        if @user_type
          User.where(user_type: @user_type)
        else
          User.all
        end
    end

    def new
      @numbers = [1, 2, 5, 10, 20, 100]
      @add_fake_users_form = AdminAddFakeUsersForm.new
    end

    def create
      form = AdminAddFakeUsersForm.new
      if form.submit(add_user_params)
        notice = <<~MSG
          Members: #{form.members}
          Bands: #{form.bands}
          Events: #{form.events}
        MSG
        redirect_to new_admin_user_path, notice: notice
      else
        redirect_to new_admin_user_path, alert: "Invalid request"
      end
    end

    def show
    end

    def edit
    end

    def update
      updated = @user.update(edit_user_params)
      if updated
        redirect_to edit_admin_user_path(@user), notice: "User updated"
      else
        flash[:alert] = @user.errors.full_messages
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy!
      redirect_to admin_users_path, notice: "User deleted."
    end

    private

    def set_user
      @user = User.find_by(username: params[:username])
      redirect_to admin_users_path, alert: "User not found" unless @user
    end

    def edit_user_params
      params.require(:user).permit(
        :username,
        :name,
        :email,
        :user_type
      )
    end

    def add_user_params
      params.require(:admin_add_fake_users_form).permit(:members, :bands, :events)
    end
  end
end
