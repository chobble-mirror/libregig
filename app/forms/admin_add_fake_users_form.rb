class AdminAddFakeUsersForm
  include ActiveModel::Model
  attr_accessor :members, :bands, :events

  validates :members, :bands, :events, presence: true
  validates :members, :bands, :events,
    numericality: {only_integer: true, greater_than_or_equal_to: 0}

  def submit(params)
    self.members = Integer(params[:members], exception: false)
    self.bands = Integer(params[:bands], exception: false)
    self.events = Integer(params[:events], exception: false)
    valid?
  end
end
