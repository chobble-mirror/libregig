module RandomId
  extend ActiveSupport::Concern

  included do
    before_create :randomise_id
  end

  private

  def randomise_id
    begin
      self.id = SecureRandom.random_number(4294967295)
    end while self.class.where(id: self.id).exists?
  end
end
