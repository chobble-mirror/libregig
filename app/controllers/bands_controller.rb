class BandsController < ApplicationController
  before_action :set_band, only: [:show, :edit, :update, :destroy]
  before_action :set_view, only: [:show, :edit, :update]

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
    if @band.save
      permission = Permission.new(
        item_type: Band,
        item_id: @band.id,
        user_id: Current.user.id,
        status: :owned,
        permission_type: :edit
      )
      permission.save!
      redirect_to @band, notice: "Band was successfully created"
    else
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
  end

  def set_view
    @views = %w[overview events shares]
    @view =
      @views.include?(params["view"]) ?
        params["view"] :
        "overview"
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
