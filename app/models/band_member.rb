class BandMember < ApplicationRecord
  include RandomId
  belongs_to :member
  belongs_to :band
end
