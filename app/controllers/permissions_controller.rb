class PermissionsController < ApplicationController
  include PermissionsHelper

  before_action :set_permission, only: [:update, :destroy]
  before_action :organiser_only, only: [:new, :create]
  before_action :set_form_options, only: [:new, :create]

  def index
    @permissions =
      if Current.user.admin?
        Permission.all
      else
        Permission.where(
          "bestowing_user_id = :user_id OR user_id = :user_id",
          user_id: Current.user.id
        )
      end

    @other_items =
      Event.permitted_for(Current.user.id) +
      Band.permitted_for(Current.user.id) +
      Member.permitted_for(Current.user.id)
  end

  def new
    @permission = Permission.new

    if params[:item_type].present? && params[:item_id].present?
      @preselected_item = "#{params[:item_type].capitalize}_#{params[:item_id]}"
    end

    @no_users_available = potential_users.empty?
  end

  def create
    params = permission_create_params
    item_param = params.delete(:item)

    @permission = Permission.new(params)
    @permission.bestowing_user = Current.user
    @permission.status = "pending"
    @permission.item_type, @permission.item_id = item_param.split("_")
    @permission.item_type&.capitalize!

    return render :new, status: :unprocessable_entity unless @permission.save

    redirect_to permissions_path, notice: "Invitation created"
  end

  def update
    params = permission_update_params
    if !@permission.user || @permission.user != Current.user
      render plain: "Not your invite", status: :forbidden
    elsif !@permission.pending?
      render plain: "Invite not pending", status: :bad_request
    else
      @permission.update(params)
      if @permission.accepted?
        redirect_to @permission.item, notice: "Invitation accepted"
      else
        redirect_to permissions_path, alert: "Invitation rejected"
      end
    end
  rescue ArgumentError
    render plain: "Not updated", status: :bad_request
  end

  def destroy
    if Current.user.admin?
      @permission.destroy!
      redirect_to root_path, notice: "Invitation deleted"
    else
      render plain: "Only organisers can create permissions.", status: :forbidden
    end
  end

  private

  def organiser_only
    unless Current.user.organiser?
      render plain: "Organisers only", status: :forbidden
    end
  end

  def set_form_options
    @users = potential_users
    @items = potential_items(Current.user)
    @permission_types = %w[view edit]
  end

  def set_permission
    @permission = Permission.find(params[:id])
  end

  def permission_create_params
    params.require(:permission).permit(:user_id, :item, :permission_type)
  end

  def permission_update_params
    params.require(:permission).permit(:status)
  end
end
