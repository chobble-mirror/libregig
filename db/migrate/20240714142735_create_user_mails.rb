class CreateUserMails < ActiveRecord::Migration[7.1]
  def change
    create_table :user_mails do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :state, default: 0
      t.string :subject
      t.string :recipient
      t.string :template
      t.json :params
      t.timestamps
    end
  end
end
