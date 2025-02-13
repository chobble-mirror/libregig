require "test_helper"

class EventsHelperTest < ActionView::TestCase
  include EventsHelper

  context "#convert_seconds_to_duration" do
    should "match expectations" do
      nothing = convert_seconds_to_duration(5)
      assert_nil nothing

      ten_minutes = convert_seconds_to_duration(600)
      assert_equal "10 minutes", ten_minutes

      two_hours = convert_seconds_to_duration(7200)
      assert_equal "2 hours", two_hours

      one_day = convert_seconds_to_duration(86400)
      assert_equal "1 day", one_day

      one_day_one_minute = convert_seconds_to_duration(86460)
      assert_equal "1 day and 1 minute", one_day_one_minute

      one_day_ten_mins = convert_seconds_to_duration(87000)
      assert_equal "1 day and 10 minutes", one_day_ten_mins

      one_day_one_hour_ten_mins = convert_seconds_to_duration(90600)
      assert_equal "1 day, 1 hour and 10 minutes", one_day_one_hour_ten_mins

      one_week = convert_seconds_to_duration(86400 * 7)
      assert_equal "7 days", one_week
    end
  end
end
