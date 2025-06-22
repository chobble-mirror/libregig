require "test_helper"

class DeviceAccessServiceTest < ActiveSupport::TestCase
  context "with a device that has full access" do
    setup do
      @user = create(:user)
      @linked_device = create(:linked_device, user: @user)
      @service = DeviceAccessService.new(@linked_device)
      
      # Create events the user can see
      @event1 = create(:event, owner: @user)
      @event2 = create(:event, owner: @user)
      
      # Create an event the user cannot see
      @other_user = create(:user)
      @event3 = create(:event, owner: @other_user)
    end
    
    should "return all events the user has permission to see" do
      events = @service.accessible_events
      
      assert_includes events, @event1
      assert_includes events, @event2
      assert_not_includes events, @event3
    end
  end
  
  context "with a device that has specific access to events" do
    setup do
      @user = create(:user)
      @linked_device = create(:linked_device, user: @user)
      @service = DeviceAccessService.new(@linked_device)
      
      # Create events
      @event1 = create(:event, owner: @user)
      @event2 = create(:event, owner: @user)
      @event3 = create(:event, owner: @user)
      
      # Grant specific access to only event1
      create(:linked_device_linkable, :for_event, 
             linked_device: @linked_device, 
             linkable: @event1)
    end
    
    should "return only specifically linked events" do
      events = @service.accessible_events
      
      assert_includes events, @event1
      assert_not_includes events, @event2
      assert_not_includes events, @event3
    end
  end
  
  context "with a device that has specific access to bands" do
    setup do
      @user = create(:user)
      @linked_device = create(:linked_device, user: @user)
      @service = DeviceAccessService.new(@linked_device)
      
      # Create bands
      @band1 = create(:band)
      @band2 = create(:band)
      
      # Create events
      @event1 = create(:event, owner: @user)
      @event2 = create(:event, owner: @user)
      @event3 = create(:event, owner: @user)
      
      # Associate events with bands
      @event1.bands << @band1
      @event2.bands << @band1
      @event3.bands << @band2
      
      # Grant specific access to band1
      create(:linked_device_linkable, :for_band, 
             linked_device: @linked_device, 
             linkable: @band1)
    end
    
    should "return events associated with linked bands" do
      events = @service.accessible_events
      
      assert_includes events, @event1
      assert_includes events, @event2
      assert_not_includes events, @event3
    end
  end
  
  context "with a device that has mixed specific access" do
    setup do
      @user = create(:user)
      @linked_device = create(:linked_device, user: @user)
      @service = DeviceAccessService.new(@linked_device)
      
      # Create a band
      @band = create(:band)
      
      # Create events
      @direct_event = create(:event, owner: @user, name: "Direct Event")
      @band_event = create(:event, owner: @user, name: "Band Event")
      @both_event = create(:event, owner: @user, name: "Both Event")
      @neither_event = create(:event, owner: @user, name: "Neither Event")
      
      # Associate events with band
      @band_event.bands << @band
      @both_event.bands << @band
      
      # Grant specific access
      create(:linked_device_linkable, :for_event, 
             linked_device: @linked_device, 
             linkable: @direct_event)
      create(:linked_device_linkable, :for_event, 
             linked_device: @linked_device, 
             linkable: @both_event)
      create(:linked_device_linkable, :for_band, 
             linked_device: @linked_device, 
             linkable: @band)
    end
    
    should "return union of directly linked events and band-linked events" do
      events = @service.accessible_events
      
      assert_includes events, @direct_event
      assert_includes events, @band_event
      assert_includes events, @both_event
      assert_not_includes events, @neither_event
      
      # Should not have duplicates
      assert_equal 3, events.count
    end
  end
end