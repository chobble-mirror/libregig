class Skill < ApplicationRecord
  has_many :member_skills, dependent: :destroy
  has_many :members, through: :member_skills

  validates :name, presence: true
end
