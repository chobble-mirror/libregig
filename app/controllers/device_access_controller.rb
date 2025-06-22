class DeviceAccessController < ApplicationController
  skip_before_action :require_login
  
  before_action :authenticate_device
  before_action :track_device_access
  
  private
  
  def authenticate_device
    @linked_device = LinkedDevice.active.find_by(
      secret: params[:secret],
      device_type: allowed_device_types
    )
    
    raise ActiveRecord::RecordNotFound unless @linked_device
  end
  
  def track_device_access
    @linked_device.touch_access!
  end
  
  def accessible_events
    @accessible_events ||= DeviceAccessService
      .new(@linked_device)
      .accessible_events
      .order(start_date: :asc)
  end
  
  def allowed_device_types
    raise NotImplementedError, "Subclass must define allowed_device_types"
  end
end