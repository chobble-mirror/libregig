class RemoveUserIdFromModels < ActiveRecord::Migration[6.1]
  def up
    remove_column :bands, :user_id, :integer
    remove_column :events, :user_id, :integer
    remove_column :members, :user_id, :integer
  end

  def down
    add_column :bands, :user_id, :integer
    add_column :events, :user_id, :integer
    add_column :members, :user_id, :integer
  end
end
