class RenameDateToStartDateAndAddEndDateToEvents < ActiveRecord::Migration[6.1]
  def change
    rename_column :events, :date, :start_date
    add_column :events, :end_date, :datetime
  end
end
