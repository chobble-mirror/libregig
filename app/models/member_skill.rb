class MemberSkill < ApplicationRecord
  belongs_to :member
  belongs_to :skill

  validates :member_id, uniqueness: { scope: :skill_id }
end
