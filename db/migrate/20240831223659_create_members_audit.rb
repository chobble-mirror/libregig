class CreateMembersAudit < ActiveRecord::Migration[6.1]
  def change
    create_table :members_audit do |t|
      t.integer :member_id, null: false
      t.integer :user_id, null: false
      t.string :column_changed, null: false
      t.string :old_value
      t.timestamps
    end

    add_index :members_audit, :member_id
  end
end
