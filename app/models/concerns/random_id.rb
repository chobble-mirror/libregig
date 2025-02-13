module RandomId
  extend ActiveSupport::Concern

  included do
    before_create :randomise_id
  end

  private

  def randomise_id
    loop do
      self.id = SecureRandom.random_number(4294967295)
      break unless self.class.where(id: id).exists?
    end
  end
end
