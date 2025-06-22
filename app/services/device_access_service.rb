class DeviceAccessService
  def initialize(linked_device)
    @linked_device = linked_device
  end

  def accessible_events
    if @linked_device.has_specific_access?
      # Get events directly linked to device
      event_ids = @linked_device.linked_device_linkables
                                .where(linkable_type: "Event")
                                .pluck(:linkable_id)
      
      # Get events through linked bands
      band_ids = @linked_device.linked_device_linkables
                               .where(linkable_type: "Band")
                               .pluck(:linkable_id)
      event_ids_from_bands = EventBand.where(band_id: band_ids).pluck(:event_id)
      
      # Combine all accessible event IDs
      all_event_ids = (event_ids + event_ids_from_bands).uniq
      Event.where(id: all_event_ids)
    else
      # Full access - get all events user can see
      Event.permitted_for(@linked_device.user_id)
    end
  end
end