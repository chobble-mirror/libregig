require "test_helper"

class LinkedDeviceTest < ActiveSupport::TestCase
  context "validations" do
    should validate_presence_of(:name)
    should validate_presence_of(:device_type)

    should belong_to(:user)
    should have_many(:linked_device_linkables)
    should have_many(:event_linkables)
    should have_many(:band_linkables)
    should have_many(:member_linkables)

    context "with an existing record" do
      setup do
        @device = create(:linked_device)
      end

      should "validate uniqueness of secret" do
        duplicate = build(:linked_device, secret: @device.secret)
        assert_not duplicate.valid?
        assert_includes duplicate.errors[:secret], "has already been taken"
      end

      should "allow creating a device with no linkables or with specific resources" do
        user = create(:user)

        # Create a device with no linkables
        device = build(:linked_device, user: user, user_account: nil)
        assert device.valid?, "Device should be valid with no selections"

        # Create a device with specific resource
        device = build(:linked_device, user: user)
        device.event_ids = [create(:event).id.to_s]
        assert device.valid?, "Device should be valid with specific resources"
      end
    end
  end

  context "generating secret" do
    should "generate a secret on create" do
      device = build(:linked_device, secret: nil)
      assert_nil device.secret
      device.save!
      assert_not_nil device.secret
      assert_equal 64, device.secret.length
    end
  end

  context "polymorphic associations" do
    should "allow linking to multiple resources" do
      user = create(:user)
      device = build(:linked_device, user: user, user_account: nil)
      device.skip_access_validation!
      device.save!

      # Add linkables
      event = create(:event)
      band = create(:band)
      member = create(:member)

      device.event_ids = [event.id]
      device.band_ids = [band.id]
      device.member_ids = [member.id]
      device.save!

      # Check associations
      assert_equal 3, device.reload.linked_device_linkables.count
      assert_equal 1, device.event_linkables.count
      assert_equal 1, device.band_linkables.count
      assert_equal 1, device.member_linkables.count

      # Verify IDs are correct
      assert_equal [event.id.to_s], device.event_ids
      assert_equal [band.id.to_s], device.band_ids
      assert_equal [member.id.to_s], device.member_ids
    end

    should "handle removing linkables" do
      user = create(:user)
      device = build(:linked_device, user: user, user_account: nil)
      device.skip_access_validation!
      device.save!

      event1 = create(:event)
      event2 = create(:event)

      # Add both events
      device.event_ids = [event1.id, event2.id]
      device.save!

      assert_equal 2, device.reload.event_linkables.count

      # Remove one event
      device.event_ids = [event1.id]
      device.save!

      assert_equal 1, device.reload.event_linkables.count
      assert_equal [event1.id.to_s], device.event_ids
    end

    should "keep linkables regardless of user_account value" do
      user = create(:user)
      device = build(:linked_device, user: user, user_account: nil)
      device.save!

      # Add linkables of different types
      event = create(:event)
      band = create(:band)

      device.event_ids = [event.id]
      device.band_ids = [band.id]
      device.save!

      assert_equal 2, device.reload.linked_device_linkables.count

      # In the new interface, user_account no longer clears linkables
      device.user_account = "1"
      device.save!

      # Should still have the linkables
      assert_equal 2, device.reload.linked_device_linkables.count
    end
  end

  context "revocation" do
    should "check if device is revoked" do
      device = create(:linked_device)
      assert_not device.revoked?

      device.update!(revoked_at: Time.current)
      assert device.revoked?
    end

    should "revoke the device" do
      device = create(:linked_device)
      assert_nil device.revoked_at

      device.revoke!
      assert_not_nil device.revoked_at
    end

    should "scope active and revoked devices" do
      user = create(:user)
      active_device = create(:linked_device, user: user)
      revoked_device = create(:linked_device, user: user, revoked_at: Time.current)

      active_devices = LinkedDevice.active
      revoked_devices = LinkedDevice.revoked

      assert_includes active_devices, active_device
      assert_not_includes active_devices, revoked_device

      assert_includes revoked_devices, revoked_device
      assert_not_includes revoked_devices, active_device
    end
  end

  context "access tracking" do
    should "update last_accessed_at" do
      device = create(:linked_device, last_accessed_at: nil)
      assert_nil device.last_accessed_at

      device.touch_access!
      assert_not_nil device.last_accessed_at
    end

    should "prevent deletion if device has been accessed" do
      device = create(:linked_device)
      device.touch_access!

      assert device.accessed?
      assert_no_difference "LinkedDevice.count" do
        assert_raises(ActiveRecord::RecordNotDestroyed) do
          device.destroy!
        end
      end

      assert_includes device.errors[:base], "Cannot delete a device that has been accessed"
    end

    should "allow deletion if device has never been accessed" do
      device = create(:linked_device, last_accessed_at: nil)
      assert_not device.accessed?

      assert_difference "LinkedDevice.count", -1 do
        device.destroy!
      end
    end
  end

  context "URL generation" do
    setup do
      Rails.application.config.server_url = "https://example.com"
    end

    context "calendar_url" do
      should "return calendar URL for web devices" do
        device = create(:linked_device, device_type: :web, secret: "test-secret")
        expected_url = "https://example.com/calendar/test-secret"
        assert_equal expected_url, device.calendar_url
      end

      should "return nil for non-web devices" do
        ical_device = create(:linked_device, device_type: :ical)
        api_device = create(:linked_device, device_type: :api)
        
        assert_nil ical_device.calendar_url
        assert_nil api_device.calendar_url
      end
    end

    context "ical_url" do
      should "return iCal URL for ical devices" do
        device = create(:linked_device, device_type: :ical, secret: "test-secret")
        expected_url = "https://example.com/ical/test-secret.ics"
        assert_equal expected_url, device.ical_url
      end

      should "return iCal URL for web devices" do
        device = create(:linked_device, device_type: :web, secret: "test-secret")
        expected_url = "https://example.com/ical/test-secret.ics"
        assert_equal expected_url, device.ical_url
      end

      should "return nil for api devices" do
        api_device = create(:linked_device, device_type: :api)
        assert_nil api_device.ical_url
      end
    end
  end
end
