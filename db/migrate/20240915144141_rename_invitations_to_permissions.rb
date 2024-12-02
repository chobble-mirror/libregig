class RenameInvitationsToPermissions < ActiveRecord::Migration[7.1]
  def change
    rename_table :invitations, :permissions
    change_table :permissions do |t|
      t.rename :receiver_id, :user_id
      t.rename :sender_id, :bestowing_user_id
    end
  end
end
