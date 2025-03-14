class CreateLinkedDevices < ActiveRecord::Migration[8.0]
  def change
    create_table :linked_devices do |t|
      t.string :name, null: false
      t.references :user, null: false, foreign_key: true
      t.integer :device_type, null: false
      t.string :secret, null: false
      t.datetime :last_accessed_at
      t.datetime :revoked_at
      t.references :linkable, polymorphic: true, null: true

      t.timestamps
    end
    
    add_index :linked_devices, :secret, unique: true
  end
end
