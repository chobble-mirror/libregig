require "test_helper"

class SkillTest < ActiveSupport::TestCase
  should have_many :member_skills
  should have_many :members

  should validate_presence_of :name
end
