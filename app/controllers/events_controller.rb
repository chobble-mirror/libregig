class EventsController < ApplicationController
  before_action :set_event, only: %i[show edit update destroy]
  before_action :set_bands, only: %i[new edit update]

  def index
    @events = Current.user.events
      .then { |rel| filter_by_period(rel, params[:period]) }
      .then { |rel| filter_by_band(rel, params[:band_id]) }
      .then { |rel| sort_results(rel, params[:sort]) }
  end

  def new
    @event = Event.new
  end

  def show
  end

  def edit
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      create_owner_permission(@event)
      redirect_to @event, notice: "Event was successfully created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: "Event was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy!
    redirect_to events_url, notice: "Event was successfully destroyed."
  rescue ActiveRecord::RecordNotDestroyed
    redirect_to @event, alert: @event.errors.full_messages.to_sentence
  end

  private

  def set_event
    @event = Current.user.events.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to events_url, alert: "Event not found."
  end

  def set_bands
    @bands = Current.user.bands
  end

  def filter_by_period(events, period)
    case period
    when "past" then events.past
    when "future", nil then events.future
    else events
    end
  end

  def filter_by_band(events, band_id)
    return events unless band_id.present? && band_id.to_i.positive?

    events.joins(:bands).where(bands: {id: band_id})
  end

  def sort_results(events, sort_param)
    column, direction = extract_sort_params(sort_param)
    return events unless Event.attribute_names.include?(column.to_s)

    events.order(column => direction)
  end

  def extract_sort_params(sort_param)
    col, dir = sort_param.to_s.split
    dir = %w[desc DESC].include?(dir) ? :desc : :asc
    [col.presence || :date, dir]
  end

  def event_params
    params.require(:event).permit(:name, :description, :date)
  end

  def create_owner_permission(event)
    event.permissions.create!(
      user: Current.user,
      status: :owned,
      permission_type: :edit
    )
  end
end
