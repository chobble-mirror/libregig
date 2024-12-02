class CreateBands < ActiveRecord::Migration[6.0]
  def change
    create_table :bands do |t|
      t.text :description, default: "", null: false
      t.references :user, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end
