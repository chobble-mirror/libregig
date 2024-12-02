class AddIndexToBandsName < ActiveRecord::Migration[6.0]
  def change
    add_index :bands, :name
  end
end
