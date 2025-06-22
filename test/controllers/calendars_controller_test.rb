require "test_helper"

class CalendarsControllerTest < ActionDispatch::IntegrationTest
  context "accessing calendar with a web device" do
    setup do
      @user = create(:user)
      # Create a web-type linked device
      @linked_device = create(:linked_device, user: @user, device_type: :web, name: "Test Web Device")
    end

    should "show calendar when a valid secret is provided" do
      get calendar_url(@linked_device.secret)
      assert_response :success
      assert_select "h1", "Calendar"
      assert_select "p", /This calendar shows events for Test Web Device/
    end

    should "return 404 when an invalid secret is provided" do
      get calendar_url("invalid-secret")
      assert_response :not_found
    end

    should "return 404 when the device has been revoked" do
      @linked_device.update!(revoked_at: Time.current)
      get calendar_url(@linked_device.secret)
      assert_response :not_found
    end

    should "update last_accessed_at when viewing the calendar" do
      assert_nil @linked_device.last_accessed_at

      get calendar_url(@linked_device.secret)

      @linked_device.reload
      assert_not_nil @linked_device.last_accessed_at
    end
  end

  context "accessing calendar with a device that has full access" do
    setup do
      @user = create(:user)
      @linked_device = create(:linked_device, user: @user, device_type: :web)

      # Create events owned by the user
      @event1 = create(:event, owner: @user, name: "Full Access Event 1")
      @event2 = create(:event, owner: @user, name: "Full Access Event 2")
    end

    should "display all events for the user" do
      get calendar_url(@linked_device.secret)

      assert_response :success
      assert_select ".event-item", count: 2
      assert_select "h2", "Full Access Event 1"
      assert_select "h2", "Full Access Event 2"
    end
  end

  context "accessing calendar with a device that has specific access" do
    setup do
      @user = create(:user)
      @linked_device = create(:linked_device, user: @user, device_type: :web)

      # Create some events
      @event1 = create(:event, owner: @user, name: "Specific Access Event 1")
      @event2 = create(:event, owner: @user, name: "Specific Access Event 2")
      @event3 = create(:event, owner: @user, name: "Specific Access Event 3")

      # Set specific access to only some events
      create(:linked_device_linkable, :for_event, linked_device: @linked_device, linkable: @event1)

      # Create a band and link it to the device
      @band = create(:band, name: "Test Band")
      create(:linked_device_linkable, :for_band, linked_device: @linked_device, linkable: @band)

      # Associate event3 with the band
      @event3.bands << @band
    end

    should "only display events that the device has access to" do
      get calendar_url(@linked_device.secret)

      assert_response :success
      assert_select ".event-item", count: 2
      assert_select "h2", "Specific Access Event 1"
      assert_select "h2", "Specific Access Event 3"
      assert_select "h2", text: "Specific Access Event 2", count: 0
    end
  end

  context "with different device types" do
    setup do
      @user = create(:user)
      @api_device = create(:linked_device, user: @user, device_type: :api)
      @ical_device = create(:linked_device, user: @user, device_type: :ical)
    end

    should "not display calendar for non-web devices" do
      get calendar_url(@api_device.secret)
      assert_response :not_found

      get calendar_url(@ical_device.secret)
      assert_response :not_found
    end
  end
end
