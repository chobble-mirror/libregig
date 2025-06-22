class CalendarsController < DeviceAccessController
  layout "application"

  def show
    @events = accessible_events
  end
  
  private
  
  def allowed_device_types
    [:web]
  end
end
