require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_organiser = create(:user_organiser)

    @band_one = create(
      :band_with_members,
      owner: @user_organiser
    )

    assert_equal @user_organiser, @band_one.owner

    @event_one = create(
      :event_future,
      bands: [@band_one],
      owner: @user_organiser
    )

    assert_equal @user_organiser, @event_one.owner

    @band_two = create(
      :band_with_members,
      owner: @user_organiser
    )

    assert_equal @user_organiser, @band_two.owner

    @event_two = create(
      :event_past,
      bands: [@band_two],
      owner: @user_organiser
    )

    assert_equal @user_organiser, @event_two.owner

    @other_band = create(:band_with_members)
  end

  context "#index" do
    context "when no band is set" do
      should "get index" do
        log_in_as @user_organiser
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
        log_in_as @user_organiser
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
        log_in_as @user_organiser
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
        log_in_as @user_organiser
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
      @new_owner = create(:user_organiser)
      @events =
        ["ZZZ", "AAA", "MMM"].map.with_index do |name, index|
          created = (index + 1).days.ago.floor
          date = Time.zone.today.next_day(index)
          create(
            :event,
            name: "#{name} Event",
            created_at: created,
            start_date: date,
            end_date: date,
            owner: @new_owner
          )
        end
      log_in_as @new_owner
    end

    {
      nil => :start_date_asc,
      "start_date ASC" => :start_date_asc,
      "start_date DESC" => :start_date_desc,
      "name DESC" => :name_desc,
      "created_at ASC" => :created_asc,
      "created_at DESC" => :created_desc,
      "invalid_column ASC" => :start_date_asc
    }.each do |sort_param, expected_order|
      should "sort events correctly with sort param '#{sort_param}' / #{expected_order}" do
        get events_url, params: {sort: sort_param, period: "all"}

        expected_events =
          case expected_order
          when :start_date_asc
            [@events[0], @events[1], @events[2]]
          when :start_date_desc
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

        assigned_events_array = assigns(:events).to_a

        assert_equal expected_events.length, assigned_events_array.length
        assert_equal expected_events, assigned_events_array
      end
    end
  end

  context "#update" do
    should "update event" do
      log_in_as @user_organiser
      patch event_url(@event_one), params: event_params(
        name: "Updated Name",
        description: "Updated Description"
      )

      assert_redirected_to event_url(@event_one)
      assert_equal "Event was successfully updated.", flash[:notice]

      @event_one.reload
      assert_equal "Updated Name", @event_one.name
      assert_equal "Updated Description", @event_one.description
    end

    should "render edit form if update fails" do
      log_in_as @user_organiser
      Event.any_instance.expects(:update).returns(false)

      patch event_url(@event_one), params: event_params(
        name: "Updated Name",
        description: "Updated Description"
      )

      assert_response :unprocessable_entity
      assert_template :edit
    end

    should "redirect if event not found" do
      log_in_as @user_organiser
      patch event_url(-1), params: event_params(
        name: "Updated Name",
        description: "Updated Description"
      )
      assert_response :not_found
    end

    should "update event with new bands" do
      log_in_as @user_organiser
      @band_three = create(:band, owner: @user_organiser)

      patch event_url(@event_one), params: event_params(
        name: @event_one.name,
        description: @event_one.description,
        band_ids: [@band_two.id, @band_three.id]
      )

      assert_redirected_to event_url(@event_one)
      @event_one.reload

      assert_equal 2, @event_one.bands.count
      assert_includes @event_one.bands, @band_two
      assert_includes @event_one.bands, @band_three
      refute_includes @event_one.bands, @band_one
    end

    should "handle empty band selection" do
      log_in_as @user_organiser
      patch event_url(@event_one), params: event_params(
        name: @event_one.name,
        description: @event_one.description,
        band_ids: []
      )

      assert_redirected_to event_url(@event_one)
      @event_one.reload

      assert_empty @event_one.bands
    end

    should "update event with empty name and description" do
      log_in_as @user_organiser
      patch event_url(@event_one), params: event_params(
        name: "",
        description: ""
      )

      # Debug failing tests by showing error messages
      if response.status == 422
        puts "Event validation errors: #{@controller.instance_variable_get(:@event).errors.full_messages}"
      end

      assert_redirected_to event_url(@event_one)
      @event_one.reload

      assert_equal "", @event_one.name
      assert_equal "", @event_one.description
    end

    should "update event with empty start_date" do
      log_in_as @user_organiser
      patch event_url(@event_one), params: event_params(
        name: "Name",
        description: "Description",
        start_date: nil
      )
      assert_redirected_to event_url(@event_one)
      @event_one.reload
      assert_nil @event_one.start_date
    end

    should "not update event with invalid start_date" do
      log_in_as @user_organiser
      # this doesn't test for invalid dates like the 30th February or leap days
      # or owt - a job for another day
      patch event_url(@event_one), params: event_params(
        name: "Name",
        description: "Description",
        start_date: "2000-00-00"
      )
      assert_redirected_to event_url(@event_one)
      @event_one.reload
      assert_nil @event_one.start_date
    end

    should "update event with valid start_date" do
      log_in_as @user_organiser
      patch event_url(@event_one), params: event_params(
        name: "Name",
        description: "Description",
        start_date: "2000-01-02 23:55"
      )
      assert_redirected_to event_url(@event_one)
      @event_one.reload
      assert_equal Time.zone.local(2000, 1, 2, 23, 55), @event_one.start_date
    end

    should "update event with valid start_date and time" do
      log_in_as @user_organiser
      patch event_url(@event_one), params: {
        event: {
          name: "Name",
          description: "Description",
          "start_date(1i)": 2000,
          "start_date(2i)": 1,
          "start_date(3i)": 2,
          "start_date(4i)": 23,
          "start_date(5i)": 15
        }
      }
      assert_redirected_to event_url(@event_one)
      @event_one.reload
      assert_equal Time.zone.local(2000, 1, 2, 23, 15), @event_one.start_date
    end

    should "not update event with invalid start_date and time" do
      log_in_as @user_organiser
      existing_date = @event_one.start_date
      assert_raise ActiveRecord::MultiparameterAssignmentErrors do
        patch event_url(@event_one), params: {
          event: {
            name: "Name",
            description: "Description",
            "start_date(1i)": 2000,
            "start_date(2i)": 0,
            "start_date(3i)": 0,
            "start_date(4i)": 25,
            "start_date(5i)": 80
          }
        }
      end
      assert_equal status, 200
      @event_one.reload
      assert_equal existing_date, @event_one.start_date
    end
  end

  context "#new" do
    should "create a new event" do
      log_in_as @user_organiser
      get new_event_url
      assert assigns(:event)
    end

    should "pre-check bands when their IDs are passed as band_id" do
      log_in_as @user_organiser
      get new_event_url(band_id: @band_one.id)
      event = assigns(:event)
      assert_equal [@band_one], event.bands
    end

    should "not pre-check bands if I don't have access to their IDs" do
      log_in_as @user_organiser
      get new_event_url(band_id: @other_band.id)
      event = assigns(:event)
      assert_equal [], event.bands
    end
  end

  context "#create" do
    should "create event with associated bands" do
      log_in_as @user_organiser
      @band = create(:band_with_members, owner: @user_organiser)
      assert_difference "Event.count" do
        url = events_url(band_id: @band_one.id)
        post url, params: event_params(
          band_ids: [@band.id]
        )
      end

      assert_response :redirect
      event = assigns(:event)
      assert_equal event.bands, [@band]
    end

    should "create event with multiple bands" do
      log_in_as @user_organiser
      band_one = create(:band_with_members, owner: @user_organiser)
      band_two = create(:band_with_members, owner: @user_organiser)

      assert_difference "Event.count" do
        post events_url, params: event_params(
          name: "New Event",
          description: "New Description",
          band_ids: [band_one.id, band_two.id]
        )
      end

      assert_response :redirect
      event = assigns(:event)
      assert_equal 2, event.bands.count
      assert_includes event.bands, band_one
      assert_includes event.bands, band_two
    end

    should "assign event to organiser as owner" do
      log_in_as @user_organiser
      organiser_user = create(:user_organiser)
      band_one = create(:band_with_members, owner: organiser_user)
      log_in_as(organiser_user)

      assert_difference "Event.count", 1 do
        post events_url, params: event_params(
          name: "New Event",
          description: "New Description",
          band_ids: [band_one.id]
        )
      end

      assert_response :redirect
      event = assigns(:event)
      assert_equal organiser_user, event.owner
    end

    should "only let organiser create events for their own bands" do
      organiser_user = create(:user_organiser)
      band_one = create(:band_with_members, owner: organiser_user)
      band_two = create(:band_with_members)

      organiser_user = band_one.owner
      # band_two has a different owner

      log_in_as(organiser_user)

      assert_raise ArgumentError do
        post events_url, params: event_params(
          name: "New Event",
          description: "New Description",
          band_ids: [band_one.id, band_two.id]
        )
      end
    end

    should "render an error if save fails" do
      log_in_as @user_organiser
      Event.any_instance.expects(:save).returns(false)

      post events_url, params: event_params(
        name: "New Event",
        description: "New Description",
        band_ids: [@band_one.id]
      )

      assert_response :unprocessable_entity
      assert_template :new
    end
  end

  context "#destroy" do
    should "destroy event" do
      log_in_as @user_organiser
      assert_difference("Event.count", -1) do
        delete event_url(@event_one)
      end

      assert_redirected_to events_url
      assert_equal "Event was successfully destroyed.", flash[:notice]
    end

    should "redirect if event not found" do
      log_in_as @user_organiser
      assert_no_difference "Event.count" do
        delete event_url(-1)
      end

      assert_response :not_found
    end

    should "handle failed destruction" do
      log_in_as @user_organiser
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

  def event_params(
    name: "New Event",
    description: "Description",
    start_date: 1.day.from_now,
    band_ids: []
  )
    {
      event: {
        name:,
        description:,
        start_date:,
        band_ids:
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
