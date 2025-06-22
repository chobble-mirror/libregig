require "test_helper"

class LinkedDevicesControllerTest < ActionDispatch::IntegrationTest
  context "with a logged in user" do
    setup do
      @user = create(:user)
      log_in_as(@user)
      @linked_device = create(:linked_device, user: @user)
    end

    context "viewing devices" do
      should "get index" do
        get linked_devices_url
        assert_response :success
        assert_not_nil assigns(:linked_devices)
      end

      should "show linked_device" do
        get linked_device_url(@linked_device)
        assert_response :success
      end
      
      should "show iCal URL for ical devices" do
        ical_device = create(:linked_device, user: @user, device_type: :ical)
        get linked_device_url(ical_device)
        assert_response :success
        assert_match ical_device.ical_url, @response.body
        assert_match "iCal Feed URL:", @response.body
      end
      
      should "show calendar URL for web devices" do
        web_device = create(:linked_device, user: @user, device_type: :web)
        get linked_device_url(web_device)
        assert_response :success
        assert_match web_device.calendar_url, @response.body
        assert_match "Public Calendar URL:", @response.body
      end

      should "filter by status" do
        active_device = create(:linked_device, user: @user)
        revoked_device = create(:linked_device, user: @user, revoked_at: Time.current)

        # Test active filter
        get linked_devices_url(status: "active")
        assert_response :success
        assert_includes assigns(:linked_devices), active_device
        assert_not_includes assigns(:linked_devices), revoked_device

        # Test revoked filter
        get linked_devices_url(status: "revoked")
        assert_response :success
        assert_not_includes assigns(:linked_devices), active_device
        assert_includes assigns(:linked_devices), revoked_device
      end

      should "filter by device type" do
        api_device = create(:linked_device, user: @user, device_type: :api)
        web_device = create(:linked_device, user: @user, device_type: :web)

        # Test API filter
        get linked_devices_url(device_type: "api")
        assert_response :success
        assert_includes assigns(:linked_devices), api_device
        assert_not_includes assigns(:linked_devices), web_device

        # Test web filter
        get linked_devices_url(device_type: "web")
        assert_response :success
        assert_not_includes assigns(:linked_devices), api_device
        assert_includes assigns(:linked_devices), web_device
      end

      should "sort results" do
        LinkedDevice.delete_all
        device1 = create(:linked_device, user: @user, name: "AAA Device")
        device2 = create(:linked_device, user: @user, name: "ZZZ Device")

        # Test name sort (ascending)
        get linked_devices_url(sort: "name")
        assert_response :success
        assert_equal device1, assigns(:linked_devices).first
        assert_equal device2, assigns(:linked_devices).last

        # Test name sort (descending)
        get linked_devices_url(sort: "name desc")
        assert_response :success
        assert_equal device2, assigns(:linked_devices).first
        assert_equal device1, assigns(:linked_devices).last
      end
    end

    context "creating devices" do
      should "get new" do
        get new_linked_device_url
        assert_response :success
      end

      should "create linked_device with user account access" do
        assert_difference("LinkedDevice.count") do
          post linked_devices_url, params: {
            linked_device: {
              name: "User Account Device",
              device_type: "api",
              user_account: "1"
            }
          }
        end

        device = LinkedDevice.order(created_at: :desc).first
        assert_equal 0, device.linked_device_linkables.count
        assert_redirected_to linked_device_url(device)
      end

      should "allow updating device without affecting linkables" do
        # Create a device with a linkable
        event = create(:event)
        device = create(:linked_device, user: @user)

        # Add linkable via virtual attribute
        device.event_ids = [event.id]
        device.save!

        # Ensure we have one linkable
        device.reload
        assert device.linked_device_linkables.any?

        # Update the device name without touching linkables
        patch linked_device_url(device), params: {
          linked_device: {
            name: "Updated Name",
            device_type: device.device_type
          }
        }

        # Linkables should remain unchanged
        assert_redirected_to linked_device_url(device)
        device.reload
        assert_equal "Updated Name", device.name
        assert device.linked_device_linkables.any?
      end

      should "create linked_device with multiple linkables" do
        event = create(:event)
        band = create(:band)

        assert_difference("LinkedDevice.count") do
          post linked_devices_url, params: {
            linked_device: {
              name: "Multi Access Device",
              device_type: "api",
              event_ids: [event.id.to_s],
              band_ids: [band.id.to_s]
            }
          }
        end

        device = LinkedDevice.order(created_at: :desc).first
        assert_equal 2, device.linked_device_linkables.count
        assert_equal 1, device.event_linkables.count
        assert_equal 1, device.band_linkables.count
        assert_redirected_to linked_device_url(device)
      end
    end

    context "updating devices" do
      should "get edit" do
        get edit_linked_device_url(@linked_device)
        assert_response :success
      end

      should "update linked_device" do
        patch linked_device_url(@linked_device), params: {
          linked_device: {
            name: "Updated Device Name",
            user_account: "1"
          }
        }

        assert_redirected_to linked_device_url(@linked_device)
        @linked_device.reload
        assert_equal "Updated Device Name", @linked_device.name
      end

      should "revoke linked_device" do
        assert_nil @linked_device.revoked_at

        post revoke_linked_device_url(@linked_device)

        assert_redirected_to linked_device_url(@linked_device)
        @linked_device.reload
        assert_not_nil @linked_device.revoked_at
      end
    end

    context "deleting devices" do
      should "destroy linked_device if never accessed" do
        assert_nil @linked_device.last_accessed_at

        assert_difference("LinkedDevice.count", -1) do
          delete linked_device_url(@linked_device)
        end

        assert_redirected_to linked_devices_url
      end

      should "not destroy linked_device if it has been accessed" do
        @linked_device.update!(last_accessed_at: Time.current)

        assert_no_difference("LinkedDevice.count") do
          delete linked_device_url(@linked_device)
        end

        assert_redirected_to linked_device_url(@linked_device)
        assert_match(/Cannot delete a device that has been accessed/, flash[:alert])
      end
    end
  end
end
