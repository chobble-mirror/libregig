class AddNameToBands < ActiveRecord::Migration[7.1]
  def change
    add_column :bands, :name, :string, null: false
  end
end
