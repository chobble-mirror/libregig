class RenameInvitables < ActiveRecord::Migration[7.1]
  def change
    change_table :permissions do |t|
      t.rename :invitable_id, :item_id
      t.rename :invitable_type, :item_type
    end
  end
end
