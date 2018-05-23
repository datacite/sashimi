class AddUniqueReportIndex < ActiveRecord::Migration[5.1]
  def change
    add_index :reports, [:created_by, :month, :year], unique: true, name: "index_reports_on_multiple_columns"
  end
end
