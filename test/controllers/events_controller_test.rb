require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @band_one = create(:band_with_members)
    @event_one = create(:event_future, bands: [@band_one])

    @band_two = create(:band_with_members)
    @event_two = create(:event_past, bands: [@band_two])

    @admin_user = create(:user_admin)
    log_in_as @admin_user
  end

  context "#new" do
    should "create a new event" do
      get new_event_url
      assert assigns(:event)
    end
  end

  context "#index" do
    context "when no band is set" do
      should "get index" do
        get events_url, params: {period: "all"}

        assert_response :success
        response_events = assigns(:events)

        assert response_events.present?
        assert_includes response_events, @event_one
        assert_includes response_events, @event_two
      end
    end

    context "when band is set" do
      should "show only events for band" do
        get events_url, params: {
          band_id: @band_one.id, period: "all"
        }

        assert_response :success
        response_events = assigns(:events)

        assert response_events.present?
        assert_includes response_events, @event_one
        refute_includes response_events, @event_two
      end
    end

    context "when past events requested" do
      should "show only past events" do
        get events_url, params: {period: "past"}

        assert_response :success
        response_events = assigns(:events)

        assert response_events.present?
        assert_includes response_events, @event_two
        refute_includes response_events, @event_one
      end
    end

    context "when future events requested" do
      should "show only future events" do
        get events_url, params: {period: "future"}

        assert_response :success
        response_events = assigns(:events)

        assert response_events.present?
        assert_includes response_events, @event_one
        refute_includes response_events, @event_two
      end
    end
  end

  context "#index sorting" do
    setup do
      @user = create(:user)
      @events = ["ZZZ", "AAA", "MMM"].map.with_index do |name, index|
        create(:event, name: "#{name} Event", created_at: (index + 1).days.ago).tap do |event|
          create(:owned_permission, user: @user, item: event)
        end
      end
      log_in_as @user
    end

    {
      nil => :date_asc,
      "date ASC" => :date_asc,
      "date DESC" => :date_desc,
      "name DESC" => :name_desc,
      "created_at ASC" => :created_asc,
      "created_at DESC" => :created_desc,
      "invalid_column ASC" => :date_asc
    }.each do |sort_param, expected_order|
      should "sort events correctly with sort param '#{sort_param}'" do
        get events_url, params: {sort: sort_param, period: "all"}

        expected_events =
          case expected_order
          when :date_asc
            [@events[0], @events[1], @events[2]]
          when :date_desc
            [@events[2], @events[1], @events[0]]
          when :name_asc
            [@events[1], @events[2], @events[0]]
          when :name_desc
            [@events[0], @events[2], @events[1]]
          when :created_asc
            [@events[2], @events[1], @events[0]]
          when :created_desc
            [@events[0], @events[1], @events[2]]
          else
            raise "No expected order?"
          end

        assert_equal expected_events, assigns(:events).to_a
      end
    end
  end

  context "#update" do
    should "update event" do
      patch event_url(@event_one), params: event_params(
        name: "Updated Name", description: "Updated Description"
      )

      assert_redirected_to event_url(@event_one)
      assert_equal "Event was successfully updated.", flash[:notice]

      @event_one.reload
      assert_equal "Updated Name", @event_one.name
      assert_equal "Updated Description", @event_one.description
    end

    should "render edit form if update fails" do
      Event.any_instance.expects(:update).returns(false)

      patch event_url(@event_one), params: event_params(
        name: "Updated Name", description: "Updated Description"
      )

      assert_response :success
      assert_template :edit
    end

    should "redirect if event not found" do
      patch event_url(-1), params: event_params(
        name: "Updated Name", description: "Updated Description"
      )

      assert_redirected_to events_url
      assert_equal "Event not found.", flash[:alert]
    end
  end

  context "#destroy" do
    should "destroy event" do
      assert_difference("Event.count", -1) do
        delete event_url(@event_one)
      end

      assert_redirected_to events_url
      assert_equal "Event was successfully destroyed.", flash[:notice]
    end

    should "redirect if event not found" do
      assert_no_difference "Event.count" do
        delete event_url(-1)
      end

      assert_redirected_to events_url
      assert_equal "Event not found.", flash[:alert]
    end

    should "handle failed destruction" do
      Event.any_instance.stubs(:destroy).returns(false)
      Event.any_instance.stubs(:errors).returns(
        ActiveModel::Errors.new(Event.new).tap { |e| e.add(:base, "Cannot delete this event") }
      )

      delete event_url(@event_one)

      assert_redirected_to @event_one
      assert_equal "Cannot delete this event", flash[:alert]
    end
  end

  context "#index" do
    context "non-admin user" do
      setup do
        @non_admin_user = create(:user_member)
        @organiser_user = create(:user_organiser)

        log_in_as @non_admin_user
      end

      context "with own and shared events" do
        should "see only their own and shared events" do
          @user_event = create_event_with_permission(:future, @band_one)
          @shared_event = create_event_with_permission(:future, @band_two)

          get events_url

          assert_response :success
          response_events = assigns(:events)

          assert response_events.present?
          assert_includes response_events, @user_event
          assert_includes response_events, @shared_event
        end
      end

      context "with no events" do
        should "see no events" do
          get events_url

          assert_response :success
          response_events = assigns(:events)

          assert response_events.empty?
        end
      end

      context "with a mix of accepted and non-accepted permissions" do
        should "see only accepted events" do
          @accepted_event = create_event_with_permission(:future, nil, :accepted)
          @pending_event = create_event_with_permission(:future, nil, :pending)
          @rejected_event = create_event_with_permission(:future, nil, :rejected)

          get events_url

          assert_response :success
          response_events = assigns(:events)

          assert response_events.present?
          assert_includes response_events, @accepted_event
          refute_includes response_events, @pending_event
          refute_includes response_events, @rejected_event
        end
      end
    end
  end

  private

  def event_params(name:, description:)
    {
      event: {
        name: name,
        description: description,
        date: 1.day.from_now,
        band_ids: [@band_one.id]
      }
    }
  end

  def create_event_with_permission(event_time, band, status = :accepted)
    event = create(
      "event_#{event_time}",
      bands: [band].compact
    )
    create(
      :permission,
      bestowing_user: nil,
      user: @organiser_user,
      item_type: "Event",
      item_id: event.id,
      status: :owned
    )
    create(
      :permission,
      status,
      bestowing_user: @organiser_user,
      user: @non_admin_user,
      item_type: "Event",
      item_id: event.id
    )
    event
  end
end
