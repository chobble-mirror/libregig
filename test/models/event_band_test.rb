require "test_helper"

class EventBandTest < ActiveSupport::TestCase
  should belong_to :event
  should belong_to :band
end
