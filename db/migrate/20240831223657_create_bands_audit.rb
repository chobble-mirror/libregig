class CreateBandsAudit < ActiveRecord::Migration[6.1]
  def change
    create_table :bands_audit do |t|
      t.integer :band_id, null: false
      t.integer :user_id, null: false
      t.string :column_changed, null: false
      t.string :old_value
      t.timestamps
    end

    add_index :bands_audit, :band_id
  end
end
