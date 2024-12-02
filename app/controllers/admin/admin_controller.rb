module Admin
  class AdminController < ApplicationController
    before_action :require_admin!, :set_admin_border

    private

    def require_admin!
      unless Current.user.admin? || Current.impersonating?
        render plain: "Admins only",
          status: :forbidden
      end
    end

    def set_admin_border
      @admin_border = true
    end
  end
end
