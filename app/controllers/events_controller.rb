class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  def index
    @events = Current.user.events
    @events = filter_events_by_period(@events, params[:period])
    @events = filter_events_by_band(@events, params[:band_id])
    @events = sort_events(@events, params[:sort])
  end

  def new
    @event = Event.new
  end

  def edit
  end

  def show
  end

  def create
    @event = Event.new(event_params)
    if @event.save!
      permission = Permission.new(
        item_type: Event,
        item_id: @event.id,
        user_id: Current.user.id,
        status: :owned,
        permission_type: :edit
      )
      permission.save!
      redirect_to @event, notice: "Event was successfully created"
    else
      render :edit
    end
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: "Event was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    if @event.destroy
      redirect_to events_url, notice: "Event was successfully destroyed."
    else
      redirect_to @event, alert: @event.errors.full_messages.to_sentence
    end
  end

  private

  def set_event
    @event = Current.user.events.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to events_url, alert: "Event not found."
  end

  def filter_events_by_period(events, period)
    case period
    when "past"
      events.where('date < ? OR date IS NULL', Time.now.utc)
    when "future", nil
      events.where('date > ? OR date IS NULL', Time.now.utc)
    else
      events
    end
  end

  def filter_events_by_band(events, band_id)
    if band_id.present? && band_id.to_i.nonzero?
      events.joins(:bands).where(bands: {id: band_id})
    else
      events
    end
  end

  def sort_events(events, sort_param)
    sort_by, sort_order = sort_param&.split
    if sort_by.present? && Event.column_names.include?(sort_by)
      events.order(sort_by => ((sort_order == "DESC") ? :desc : :asc))
    else
      events.order(date: :asc)
    end
  end

  def event_params
    params.require(:event).permit(:name, :description, :date, :band_id)
  end
end
