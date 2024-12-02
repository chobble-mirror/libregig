class CreateEventsAudit < ActiveRecord::Migration[6.1]
  def change
    create_table :events_audit do |t|
      t.integer :event_id, null: false
      t.integer :user_id, null: false
      t.string :column_changed, null: false
      t.string :old_value
      t.timestamps
    end

    add_index :events_audit, :event_id
  end
end
