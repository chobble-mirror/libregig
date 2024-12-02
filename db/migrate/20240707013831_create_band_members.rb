class CreateBandMembers < ActiveRecord::Migration[7.1]
  def change
    create_table :band_members do |t|
      t.references :member, null: false, foreign_key: true
      t.references :band, null: false, foreign_key: true

      t.timestamps
    end
  end
end
