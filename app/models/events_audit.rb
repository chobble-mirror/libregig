class EventsAudit < ApplicationRecord
  self.table_name = "events_audit"
  belongs_to :event
end
