require "test_helper"

class EventTest < ActiveSupport::TestCase
  should have_many :event_bands
  should have_many :bands

  context "scopes" do
    setup do
      Event.destroy_all

      @today_event = create(:event)
      @future_event = create(:event_future)
      @past_event = create(:event_past)
    end

    context "past" do
      should "return events today and past events" do
        past_events = Event.past
        assert_equal 2, past_events.count
        assert_includes past_events, @today_event
        assert_includes past_events, @past_event
      end
    end

    context "future" do
      should "return future events" do
        past_events = Event.future
        assert_equal 1, past_events.count
        assert_includes past_events, @future_event
      end
    end
  end

  context "#url" do
    setup { @event = create(:event) }

    should "return correct url" do
      assert_equal "/events/#{@event.id}/edit", @event.url
    end
  end

  context "#external_url" do
    setup { @event = create(:event) }

    should "return correct url" do
      assert_equal "#{Rails.application.config.server_url}/events/#{@event.id}/edit", @event.external_url
    end
  end

  context "Event audits" do
    setup do
      @user = create(:user)
      @event = create(:event, name: "Original Name")
      Current.user = @user
    end

    should "create audit log entry for changed columns" do
      assert_difference("EventsAudit.count") do
        @event.update!(name: "Updated Name")
      end

      audit = EventsAudit.last
      assert_equal @event.id, audit.event_id
      assert_equal "name", audit.column_changed
      assert_equal "Original Name", audit.old_value
      assert_equal "Updated Name", @event.name
      assert_equal @user.id, audit.user_id
    end

    should "not log unchanged columns" do
      assert_no_difference("EventsAudit.count") do
        @event.update!(name: "Original Name")
      end
    end
  end
end
