class CreateEventBands < ActiveRecord::Migration[6.0]
  def change
    create_table :event_bands do |t|
      t.references :event, null: false, foreign_key: true
      t.references :band, null: false, foreign_key: true

      t.timestamps
    end

    add_index :event_bands, [:event_id, :band_id], unique: true
  end
end
