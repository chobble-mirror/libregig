class BandsAudit < ApplicationRecord
  self.table_name = "bands_audit"

  belongs_to :band
end
