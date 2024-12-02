module Admin
  class BandsController < AdminController
    def index
      @bands = Band.all
    end
  end
end
