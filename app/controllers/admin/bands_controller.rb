module Admin
  class BandsController < AdminController
    before_action :set_band, except: %i[
      index
    ]

    def index
      @bands = Band.all
    end

    def show
    end

    def edit
    end

    def update
      updated = @band.update(edit_band_params)
      if updated
        redirect_to edit_admin_band_path(@band), notice: "Band updated"
      else
        flash[:alert] = @band.errors.full_messages
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @band.destroy!
      redirect_to admin_bands_path, notice: "Band deleted."
    end

    private

    def set_band
      @band = Band.find(params[:id])
      redirect_to admin_bands_path, alert: "Band not found" unless @band
    end

    def edit_band_params
      params.require(:band).permit(
        :name
      )
    end
  end
end
