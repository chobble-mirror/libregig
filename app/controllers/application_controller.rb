# frozen_string_literal: true

class ApplicationController < ActionController::Base
  prepend_before_action :set_current_user
  before_action :require_login
  helper_method :show_tabs, :nav_tabs, :my_pending_invites, :body_class, :set_current_user_by_session

  def nav_tabs
    return unless show_tabs
    @nav_tabs ||= build_nav_tabs
  end

  def my_pending_invites
    return unless Current.user&.member?
    @my_pending_invites ||= Permission.where(user_id: Current.user.id, status: "pending")
  end

  def body_class
    @admin_border ? "admin-background" : ""
  end

  def show_tabs
    @show_tabs ||= Current.user.present?
  end

  private

  def set_current_user
    set_current_user_by_session(session)
  end

  def set_current_user_by_session(session)
    if session[:impersonation]
      handle_impersonation(session)
    elsif session[:user_id]
      set_regular_user(session[:user_id])
    else
      clear_current_user
    end
  end

  def handle_impersonation(session)
    impersonation = session[:impersonation]
    original_user_id =
      impersonation["original_user_id"] ||
      impersonation[:original_user_id]

    target_user_id =
      impersonation["target_user_id"] ||
      impersonation[:target_user_id]

    started_at =
      impersonation["started_at"] ||
      impersonation[:started_at]

    original_user = User.find_by(id: original_user_id)
    target_user = User.find_by(id: target_user_id)

    if valid_impersonation?(original_user, target_user, started_at)
      set_impersonated_user(original_user, target_user)
    else
      end_impersonation(session)
    end
  end

  def valid_impersonation?(original_user, target_user, started_at)
    failure_reasons = {
      original_not_admin: !original_user&.admin?,
      no_target_user: !target_user,
      missing_time: !started_at,
      too_old: started_at && started_at.to_time < 12.hours.ago
    }.select! { |k, v| !!v }.keys

    if failure_reasons.any?
      if request
        flash[:alert] = "Impersonation failed: #{failure_reasons.inspect}"
      end
      false
    else
      true
    end
  end

  def set_impersonated_user(original_user, target_user)
    Current.user = target_user
    Current.impersonator = original_user
  end

  def set_regular_user(user_id)
    user = User.find_by(id: user_id)
    if user
      Current.user = user
      Current.impersonator = nil
    else
      clear_current_user
    end
  end

  def clear_current_user
    Current.user = nil
    Current.impersonator = nil
  end

  def end_impersonation(session)
    session.delete(:impersonation)
    set_regular_user(session[:user_id])
  end

  def require_login
    return if Current.user&.confirmed? || allowed_path?

    if Current.user && !Current.user.confirmed?
      handle_unconfirmed_user
    else
      redirect_to_login
    end
  end

  def allowed_path?
    [
      login_path,
      logout_path,
      register_path,
      not_confirmed_path,
      resend_confirmation_path,
      confirm_registration_path,
      confirm_registration_submit_path
    ].include?(request.path)
  end

  def handle_unconfirmed_user
    unless [not_confirmed_path, resend_confirmation_path].include?(request.path)
      flash[:alert] = "Your account is not confirmed"
      redirect_to not_confirmed_path
    end
  end

  def redirect_to_login
    flash[:alert] = "You must be logged in"
    redirect_to login_url
  end

  def build_nav_tabs
    tabs = [
      {display_name: "Events", url: events_path},
      {display_name: "Bands", url: bands_path}
    ]

    if Current.user.admin? || Current.user.organiser?
      tabs << {display_name: "Sharing", url: permissions_path}
    end

    tabs
  end
end
