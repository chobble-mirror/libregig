class CreateInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :invitations do |t|
      t.integer :sender_id, null: false
      t.integer :receiver_id, null: false
      t.references :invitable, polymorphic: true, null: false
      t.string :permission_type, null: false
      t.string :status, null: false

      t.timestamps
    end

    add_index :invitations, :sender_id
    add_index :invitations, :receiver_id
  end
end
