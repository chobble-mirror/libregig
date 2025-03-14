class LinkedDeviceLinkable < ApplicationRecord
  belongs_to :linked_device
  belongs_to :linkable, polymorphic: true

  validates :linked_device_id, uniqueness: {
    scope: [:linkable_type, :linkable_id],
    message: "is already linked to this resource"
  }
end
