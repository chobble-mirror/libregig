require "test_helper"

class BandMemberTest < ActiveSupport::TestCase
  should belong_to :band
  should belong_to :member
end
