class IcalFeedsController < DeviceAccessController
  def show
    @events = accessible_events

    calendar = IcalGeneratorService.new(
      events: @events,
      device: @linked_device
    ).generate

    respond_to do |format|
      format.ics do
        send_data calendar.to_ical,
          type: "text/calendar",
          disposition: "attachment",
          filename: "libregig-calendar.ics"
      end
    end
  end

  private

  def allowed_device_types
    [:web, :ical]
  end
end
