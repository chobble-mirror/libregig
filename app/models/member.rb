class Member < ApplicationRecord
  include RandomId

  has_many :band_members, dependent: :destroy
  has_many :bands, through: :band_members

  has_many :member_skills, dependent: :destroy
  has_many :skills, through: :member_skills

  validates :skills, presence: true, if: -> { skills_list.present? }

  has_many :permission, as: :item, dependent: :destroy
  has_many :linked_devices, as: :linkable, dependent: :nullify

  include Auditable
  audit_log_columns :name, :description

  attribute :permission_type, :string

  scope :permitted_for, ->(user_id) {
    select(
      "members.*, #{MemberPermissionQuery.with_permission_type_sql(user_id)}"
    )
      .where(MemberPermissionQuery.permission_sql(user_id))
  }

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

  def editable?
    permission_type == "edit"
  end

  def events
    Event.joins(:bands)
      .where(bands: {id: bands.pluck(:id)})
      .distinct
  end
end
