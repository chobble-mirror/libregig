class CalendarsController < ApplicationController
  skip_before_action :require_login
  layout "application"

  def show
    @linked_device = LinkedDevice.find_by!(
      secret: params[:secret],
      device_type: :web,
      revoked_at: nil
    )

    @linked_device.touch_access!

    if @linked_device.has_specific_access?
      event_ids = @linked_device.event_linkables.pluck(:linkable_id)
      band_ids = @linked_device.band_linkables.pluck(:linkable_id)
      event_ids_from_bands = EventBand.where(
        band_id: band_ids
      ).pluck(:event_id)

      all_event_ids = (event_ids + event_ids_from_bands).uniq
      @events = Event.where(
        id: all_event_ids
      )
    else
      @events = Event.permitted_for(
        @linked_device.user_id
      )
    end

    @events.order!(start_date: :asc)
  end
end
