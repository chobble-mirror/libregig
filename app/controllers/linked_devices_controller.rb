class LinkedDevicesController < ApplicationController
  before_action :set_linked_device, only: [:show, :edit, :update, :destroy, :revoke]
  before_action :set_linkables, only: [:new, :edit, :create, :update]
  before_action :set_view, only: [:show]

  def index
    @linked_devices = Current.user.linked_devices
      .includes(:linked_device_linkables)
      .then { |rel| filter_by_status(rel, params[:status]) }
      .then { |rel| filter_by_type(rel, params[:device_type]) }
      .then { |rel| sort_results(rel, params[:sort]) }
  end

  def show
  end

  def new
    @linked_device = LinkedDevice.new

    # Set default linkable if provided in params
    if params[:linkable_type].present? && params[:linkable_id].present?
      type = params[:linkable_type]
      id = params[:linkable_id]

      if %w[Event Band Member].include?(type)
        @linked_device.linkable_type = type
        @linked_device.linkable_id = id
      end
    end
  end

  def edit
  end

  def create
    @linked_device = Current.user.linked_devices.new(linked_device_params)

    if @linked_device.save
      redirect_to @linked_device, notice: "Device successfully linked."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @linked_device.update(linked_device_params)
      redirect_to @linked_device, notice: "Device successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @linked_device.accessed?
      redirect_to(
        @linked_device,
        alert: "Cannot delete a device that has been accessed. Please revoke instead."
      )
      return
    end

    @linked_device.destroy!
    redirect_to linked_devices_url, notice: "Device successfully removed."
  rescue ActiveRecord::RecordNotDestroyed
    redirect_to(
      @linked_device,
      alert: @linked_device.errors.full_messages.to_sentence
    )
  end

  def revoke
    # For revocation, we don't need to validate access permissions
    @linked_device.skip_access_validation! if Rails.env.test?
    @linked_device.revoke!
    redirect_to @linked_device, notice: "Device successfully revoked."
  end

  private

  def set_linked_device
    @linked_device = Current.user.linked_devices.find(params[:id])
  end

  def set_linkables
    @events = Current.user.events
    @bands = Current.user.bands
    @members = Current.user.members
  end

  def set_view
    @views = %w[overview]
    @view = "overview"
  end

  def linked_device_params
    params.require(:linked_device).permit(
      :name,
      :device_type,
      event_ids: [],
      band_ids: [],
      member_ids: []
    )
  end

  def filter_by_status(relation, status)
    return relation.active if status == "active"
    return relation.revoked if status == "revoked"
    relation
  end

  def filter_by_type(relation, type)
    LinkedDevice.device_types.key?(type) ? relation.where(device_type: type) : relation
  end

  def sort_results(relation, sort)
    sort_mapping = {
      "name" => {name: :asc},
      "name desc" => {name: :desc},
      "created" => {created_at: :asc},
      "created desc" => {created_at: :desc},
      "modified" => {updated_at: :asc},
      "modified desc" => {updated_at: :desc},
      "last_accessed" => {last_accessed_at: :asc},
      "last_accessed desc" => {last_accessed_at: :desc}
    }

    relation.order(sort_mapping[sort] || {created_at: :desc})
  end
end
