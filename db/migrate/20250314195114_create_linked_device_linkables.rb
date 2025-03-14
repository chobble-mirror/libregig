class CreateLinkedDeviceLinkables < ActiveRecord::Migration[8.0]
  def change
    create_table :linked_device_linkables do |t|
      t.references :linked_device, null: false, foreign_key: true
      t.references :linkable, polymorphic: true, null: false

      t.timestamps
    end

    # Add unique constraint to prevent duplicates
    add_index :linked_device_linkables,
      [:linked_device_id, :linkable_type, :linkable_id],
      unique: true,
      name: "index_device_linkables_on_device_and_linkable"
  end
end
