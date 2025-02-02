class BandsController < ApplicationController
  include EventsHelper

  before_action :set_band, only: %i[show edit update destroy]
  before_action :set_view, only: %i[show edit update]
  before_action :verify_organiser, only: %i[create]
  before_action :verify_organiser_or_admin, only: %i[destroy]

  def index
    @bands = Current.user.bands
    @bands = sort_bands(@bands, params[:sort])

    if @bands.count == 0
      redirect_to action: :new
    elsif !Current.user.admin? && @bands.count == 1
      redirect_to @bands.first
    end
  end

  def edit
  end

  def show
  end

  def new
    @band = Band.new
  end

  def create
    @band = Band.new(band_params)

    begin
      Band.transaction do
        @band.save!
        Permission.create!(
          item_type: "Band",
          item_id: @band.id,
          user_id: Current.user.id,
          status: :owned,
          permission_type: :edit
        )
      end
      redirect_to @band, notice: "Band was successfully created"
    rescue ActiveRecord::RecordInvalid
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @band.update(band_params)
      redirect_to @band, notice: "Band was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    Rails.logger.debug { "Attempting to destroy band: #{@band.inspect}" }
    if @band.destroy
      Rails.logger.debug { "Band destroyed: #{@band.inspect}" }
      redirect_to bands_url, notice: "Band was successfully destroyed."
    else
      Rails.logger.debug { "Band cannot be deleted: #{@band.errors.inspect}" }
      redirect_to @band, alert: @band.errors.full_messages.to_sentence
    end
  end

  private

  def set_band
    @band = Current.user.bands.find(params[:id])
    @events = @band.events
      .then { |rel| filter_by_period(rel, params[:period]) }
      .then { |rel| sort_results(rel, params[:sort]) }
  end

  def set_view
    @views = %w[overview events shares]
    @views_subtitles = [nil, "(#{@band.events.count})", nil]
    @view =
      @views.include?(params["view"]) ?
        params["view"] :
        "overview"
  end

  def verify_organiser
    redirect_to bands_url unless Current.user.organiser?
  end

  def verify_organiser_or_admin
    redirect_to bands_url unless Current.user.organiser? || Current.user.admin?
  end

  def sort_bands(bands, sort_param)
    sort_by, sort_order = sort_param&.split
    if sort_by.present? && Band.column_names.include?(sort_by)
      bands.order(sort_by => ((sort_order == "DESC") ? :desc : :asc))
    else
      bands.order(name: :asc)
    end
  end

  def band_params
    params.require(:band).permit(:name, :description, member_ids: [])
  end
end
