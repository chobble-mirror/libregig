class Member < ApplicationRecord
  has_many :band_members, dependent: :destroy
  has_many :bands, through: :band_members

  has_many :member_skills, dependent: :destroy
  has_many :skills, through: :member_skills

  validates :skills, presence: true, if: -> { skills_list.present? }

  has_many :permission, as: :item, dependent: :destroy

  include Auditable
  audit_log_columns :name, :description

  def owner
    Permission.where(
      status: :owned,
      item_type: "Member",
      item_id: id
    ).first&.user
  end

  def skills_list
    skills.pluck(:name).join(", ")
  end

  def skills_list=(skills_string)
    return if skills_string.blank?

    skill_names =
      skills_string
        .downcase
        .split(",")
        .map(&:strip)
        .compact_blank
        .uniq

    return if skill_names.empty?

    transaction do
      member_skills.destroy_all
      skill_names.each do |name|
        skill = Skill.find_or_create_by!(name: name)
        member_skills.create!(skill: skill) unless member_skills.exists?(skill: skill)
      end
    end
  end

  def editable
    false
  end
end
