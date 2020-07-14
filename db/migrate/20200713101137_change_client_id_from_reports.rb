class ChangeClientIdFromReports < ActiveRecord::Migration[5.2]
  def change
    rename_column :reports, :client_id, :user_id
  end
end
