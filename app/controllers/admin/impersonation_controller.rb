module Admin
  class ImpersonationController < AdminController
    def create
      target_user = User.find(params[:user_id])
      session[:impersonation] = {
        original_user_id: Current.user.id,
        target_user_id: target_user.id,
        started_at: Time.current.utc
      }

      redirect_to(events_path, notice: "Impersonating '#{target_user.username}'")
    end

    def destroy
      unless session[:impersonation]
        return redirect_to(admin_users_path,
                          alert: "No active impersonation session")
      end

      target_user = User.find(session[:impersonation]["target_user_id"])
      original_user = User.find(session[:impersonation]["original_user_id"])
      username = target_user.username

      session[:user_id] = original_user.id
      session.delete(:impersonation)

      redirect_to(admin_users_path, notice: "Ended impersonation of #{username}")
    end
  end
end
