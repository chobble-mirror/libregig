class EventBand < ApplicationRecord
  include RandomId
  belongs_to :event
  belongs_to :band
end
