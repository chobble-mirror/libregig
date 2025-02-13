class EventsController < ApplicationController
  include AccessPermissions
  include EventsHelper

  before_action :set_bands, only: %i[new edit create update]

  def index
    @events = @events
      .then { |rel| filter_by_period(rel, params[:period]) }
      .then { |rel| filter_by_band(rel, params[:band_id]) }
      .then { |rel| sort_results(rel, params[:sort]) }
  end

  def new
    @event = Event.new
    @event.band_ids = [params[:band_id]] if params[:band_id].present?
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

  def set_bands
    @bands = Current.user.bands
  end

  def event_params
    permitted = params.require(:event).permit(
      :name,
      :description,
      :start_date,
      :end_date,
      band_ids: []
    )

    permitted_band_ids = @bands.pluck(:id)

    permitted.tap do |params|
      params[:band_ids] = params[:band_ids].to_a.compact_blank.map(&:to_i)
      invalid_bands = params[:band_ids] - permitted_band_ids
      if invalid_bands.any?
        raise ArgumentError, "Invalid band_ids: #{invalid_bands}"
      end
    end
  end

  def create_owner_permission(event)
    event.permissions.create!(
      user: Current.user,
      status: :owned,
      permission_type: :edit
    )
  end
end
