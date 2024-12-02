class AddNameToMembers < ActiveRecord::Migration[7.1]
  def change
    add_column :members, :name, :string, null: false
    add_index :members, :name
  end
end
