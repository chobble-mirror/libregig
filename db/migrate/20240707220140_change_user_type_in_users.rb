class ChangeUserTypeInUsers < ActiveRecord::Migration[6.1]
  def change
    # Ensure user_type column exists, if it doesn't you need to create it first.
    change_column_null :users, :user_type, false
  end
end
