require "test_helper"

class MemberSkillTest < ActiveSupport::TestCase
  should belong_to :member
  should belong_to :skill
end
