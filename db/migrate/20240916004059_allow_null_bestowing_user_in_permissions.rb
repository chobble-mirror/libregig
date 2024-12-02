class AllowNullBestowingUserInPermissions < ActiveRecord::Migration[6.1]
  def up
    change_column_null :permissions, :bestowing_user_id, true
  end

  def down
    change_column_null :permissions, :bestowing_user_id, false
  end
end
