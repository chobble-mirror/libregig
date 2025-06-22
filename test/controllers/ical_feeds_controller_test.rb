require "test_helper"

class IcalFeedsControllerTest < ActionDispatch::IntegrationTest
  context "accessing iCal feed with an ical device" do
    setup do
      @user = create(:user)
      @linked_device = create(:linked_device, user: @user, device_type: :ical, name: "Test iCal Device")
    end

    should "return iCal format when a valid secret is provided" do
      get ical_feed_url(@linked_device.secret, format: :ics)
      assert_response :success
      assert_equal "text/calendar", response.headers["Content-Type"]
      assert response.headers["Content-Disposition"].include?("attachment")
      assert response.headers["Content-Disposition"].include?("libregig-calendar.ics")
    end

    should "return 404 when an invalid secret is provided" do
      get ical_feed_url("invalid-secret", format: :ics)
      assert_response :not_found
    end

    should "return 404 when the device has been revoked" do
      @linked_device.update!(revoked_at: Time.current)
      get ical_feed_url(@linked_device.secret, format: :ics)
      assert_response :not_found
    end

    should "update last_accessed_at when accessing the feed" do
      assert_nil @linked_device.last_accessed_at

      get ical_feed_url(@linked_device.secret, format: :ics)

      @linked_device.reload
      assert_not_nil @linked_device.last_accessed_at
    end
  end

  context "accessing iCal feed with a web device" do
    setup do
      @user = create(:user)
      @linked_device = create(:linked_device, user: @user, device_type: :web, name: "Test Web Device")
    end

    should "allow web devices to access iCal feed" do
      get ical_feed_url(@linked_device.secret, format: :ics)
      assert_response :success
      assert_equal "text/calendar", response.headers["Content-Type"]
    end
  end

  context "accessing iCal feed with an api device" do
    setup do
      @user = create(:user)
      @api_device = create(:linked_device, user: @user, device_type: :api)
    end

    should "not allow api devices to access iCal feed" do
      get ical_feed_url(@api_device.secret, format: :ics)
      assert_response :not_found
    end
  end

  context "iCal content with full access" do
    setup do
      @user = create(:user)
      @linked_device = create(:linked_device, user: @user, device_type: :ical)

      # Create events owned by the user
      @event1 = create(:event, owner: @user, name: "Full Access Event 1",
        description: "Description 1",
        start_date: 1.day.from_now,
        end_date: 1.day.from_now + 2.hours)
      @event2 = create(:event, owner: @user, name: "Full Access Event 2",
        start_date: 2.days.from_now)
    end

    should "include all user events in iCal format" do
      get ical_feed_url(@linked_device.secret, format: :ics)

      assert_response :success

      # Parse the iCal content
      body = response.body
      assert body.include?("BEGIN:VCALENDAR")
      assert body.include?("VERSION:2.0")
      assert body.include?("PRODID:-//LibreGig//Calendar//EN")
      assert body.include?("X-WR-CALNAME:LibreGig Calendar - #{@linked_device.name}")

      # Check events are included
      assert body.include?("BEGIN:VEVENT")
      assert body.include?("SUMMARY:Full Access Event 1")
      assert body.include?("SUMMARY:Full Access Event 2")
      assert body.include?("DESCRIPTION:Description 1")
      assert body.include?("UID:event-#{@event1.id}@libregig.com")
      assert body.include?("UID:event-#{@event2.id}@libregig.com")
      assert body.include?("END:VEVENT")
      assert body.include?("END:VCALENDAR")
    end
  end

  context "iCal content with specific access" do
    setup do
      @user = create(:user)
      @linked_device = create(:linked_device, user: @user, device_type: :ical)

      # Create some events
      @event1 = create(:event, owner: @user, name: "Specific Access Event 1")
      @event2 = create(:event, owner: @user, name: "Specific Access Event 2")
      @event3 = create(:event, owner: @user, name: "Band Related Event")

      # Set specific access to only some events
      create(:linked_device_linkable, :for_event, linked_device: @linked_device, linkable: @event1)

      # Create a band and link it to the device
      @band = create(:band, name: "Test Band")
      create(:linked_device_linkable, :for_band, linked_device: @linked_device, linkable: @band)

      # Associate event3 with the band
      @event3.bands << @band
    end

    should "only include accessible events in iCal" do
      get ical_feed_url(@linked_device.secret, format: :ics)

      assert_response :success

      body = response.body
      # Should include accessible events
      assert body.include?("SUMMARY:Specific Access Event 1")
      assert body.include?("SUMMARY:Band Related Event")

      # Should include band info in description
      assert body.include?("Bands: Test Band")

      # Should NOT include non-accessible event
      assert_not body.include?("SUMMARY:Specific Access Event 2")
    end
  end
end
