class MemberSkill < ApplicationRecord
  belongs_to :member
  belongs_to :skill
end
