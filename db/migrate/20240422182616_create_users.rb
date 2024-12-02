class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :username
      t.string :name
      t.string :password_digest
      t.boolean :confirmed
      t.integer :user_type, default: 0
      t.string :time_zone

      t.timestamps
    end
  end
end
