class AddUidAndYearToReport < ActiveRecord::Migration[5.1]
  def change
    add_column :reports, :year, :string
    add_column :reports, :month, :string
    add_column :reports, :uid, :string
  end
end
