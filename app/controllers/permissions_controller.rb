class PermissionsController < ApplicationController
  include PermissionsHelper

  before_action :set_permission, only: [:update, :destroy]
  before_action :organiser_only, only: [:new, :create]
  before_action :invitee_and_pending_only, only: [:update]
  before_action :bestower_and_admin_only, only: [:destroy]
  before_action :set_form_options, only: [:new, :create]

  def index
    @permissions = Current.user.admin? ? Permission.all : Permission.for_user(Current.user)
    @permissions = sort_permissions(@permissions, params[:direct_sort])

    @other_items = fetch_effective_permissions
    @other_items = sort_effective_items(@other_items, params[:effective_sort])

    respond_to do |format|
      format.html
      format.json { render json: {permissions: @permissions, effective: @other_items} }
    end
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
    status = permission_update_params[:status]

    if @permission.update(status: status)
      if status == "accepted"
        redirect_to @permission.item_path, notice: "Invitation accepted"
      else
        redirect_to permissions_path, alert: "Invitation rejected"
      end
    else
      render plain: "Not updated", status: :bad_request
    end
  end

  def destroy
    @permission.destroy!
    redirect_to root_path, notice: "Invitation deleted"
  end

  private

  def sort_permissions(permissions, sort_param)
    return permissions.order(created_at: :desc) if sort_param.blank?

    column, direction = sort_param.split
    direction_sym = (direction&.downcase == "desc") ? :desc : :asc

    case column
    when "name"
      joins_sql = <<~SQL
        LEFT JOIN bands
          ON bands.id = permissions.item_id
          AND permissions.item_type = 'Band'
        LEFT JOIN events
          ON events.id = permissions.item_id
          AND permissions.item_type = 'Event'
        LEFT JOIN members
          ON members.id = permissions.item_id
          AND permissions.item_type = 'Member'
      SQL
      permissions.joins(joins_sql)
        .order(Arel.sql(
          "COALESCE(bands.name, events.name, members.name) #{direction_sym}"
        ))
    when "type"
      permissions.order(item_type: direction_sym)
    when "access"
      permissions.order(permission_type: direction_sym)
    when "status"
      permissions.order(status: direction_sym)
    when "bestower"
      permissions.joins(:bestowing_user).order(Arel.sql(
        "users.username #{direction_sym}"
      ))
    when "created"
      permissions.order(created_at: direction_sym)
    when "last_modified"
      permissions.order(updated_at: direction_sym)
    else
      permissions.order(created_at: :desc)
    end
  end

  def sort_effective_items(items, sort_param)
    return items.sort_by { |item| item.name.downcase } if sort_param.blank?

    column, direction = sort_param.split
    desc = (direction&.downcase == "desc")

    sorted_items = case column
    when "name"
      items.sort_by { |item| item.name.downcase }
    when "type"
      items.sort_by { |item| item.class.name }
    when "status"
      items.sort_by { |item| item.permission_type.to_s }
    when "source"
      items.sort_by do |item|
        permission = find_effective_permission_source(Current.user, item)
        if permission.nil?
          "AAA_Direct" # Sort direct permissions first
        else
          "#{permission.item_type}_#{permission.item.name}"
        end
      end
    else
      items.sort_by { |item| item.name.downcase }
    end

    desc ? sorted_items.reverse : sorted_items
  end

  def fetch_effective_permissions
    events =
      Event.permitted_for(Current.user.id)
        .includes(:bands, :permissions)

    bands =
      Band.permitted_for(Current.user.id)
        .includes(:members, :events, :permission)

    members =
      Member.permitted_for(Current.user.id)
        .includes(:bands, :skills)

    events + bands + members
  end

  def organiser_only
    unless Current.user.organiser?
      render plain: "Organisers only", status: :forbidden
    end
  end

  def bestower_and_admin_only
    unless Current.user.admin? || @permission.bestowing_user == Current.user
      render plain: "Bestower only", status: :forbidden
    end
  end

  def invitee_and_pending_only
    if @permission.user != Current.user
      render plain: "Invitee only", status: :forbidden
    elsif !@permission.pending?
      render plain: "Invite not pending", status: :bad_request
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
