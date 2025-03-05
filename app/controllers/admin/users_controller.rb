module Admin
  class UsersController < AdminController
    before_action :set_user, except: %i[
      index
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
        :user_type,
        :confirmed
      )
    end
  end
end
