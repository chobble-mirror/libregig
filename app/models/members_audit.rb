class MembersAudit < ApplicationRecord
  self.table_name = "members_audit"
  belongs_to :member
  belongs_to :user
end
