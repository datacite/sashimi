class AddExceptionsColumn < ActiveRecord::Migration[5.2]
  def change
    add_column :report_subsets, :exceptions, :json
  end
end
