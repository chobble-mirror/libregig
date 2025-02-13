class BandsController < ApplicationController
  include EventsHelper

  before_action :get_bands
  before_action :set_band, except: %i[index new create]
  # before_action :deny_read_only, only: %i[edit update destroy]

  before_action :set_events, except: %i[index new create]
  before_action :set_view, only: %i[show edit update confirm_destroy]
  before_action :verify_organiser, only: %i[new create]
  before_action :verify_organiser_or_admin, only: %i[confirm_destroy destroy]

  def index
    @bands =
      Current.user.admin? ?
        Band.all :
        Current.user.bands
    @bands = sort_bands(@bands, params[:sort])

    bands_count = @bands.to_a.count

    if bands_count == 0
      redirect_to action: :new
    elsif Current.user.member? && bands_count == 1
      redirect_to @bands.first
    end
  end

  def edit
  end

  def show
  end

  def confirm_destroy
    @view = "overview"
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
    if @band.destroy
      redirect_to bands_url, notice: "Band deleted!"
    else
      redirect_to @band, alert: @band.errors.full_messages.to_sentence
    end
  end

  private

  def get_bands
    @bands = Current.user.admin? ? Band.all : Current.user.bands
  end

  def set_band
    @band = @bands.find(params[:id])
    redirect_to bands_url unless @band
  end

  def deny_read_only
    redirect_to @band unless @band.permission_type == "edit"
  end

  def set_band
    @band = Current.user.bands.find(params[:id])
  end

  def set_events
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
