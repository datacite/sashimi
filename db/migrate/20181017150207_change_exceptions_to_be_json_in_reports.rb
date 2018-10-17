class ChangeExceptionsToBeJsonInReports < ActiveRecord::Migration[5.1]
  def change
    change_column :reports, :exceptions, :json
  end
end
