class Member < ApplicationRecord
  has_many :band_members, dependent: :destroy
  has_many :bands, through: :band_members

  has_many :member_skills, dependent: :destroy
  has_many :skills, through: :member_skills

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

  def editable
    false
  end
end
