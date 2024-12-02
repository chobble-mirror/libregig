class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.text :description, null: false, default: ""
      t.datetime :date
      t.references :user, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end
