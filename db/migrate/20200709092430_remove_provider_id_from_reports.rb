class RemoveProviderIdFromReports < ActiveRecord::Migration[5.2]
  def change
    remove_column :reports, :provider_id, :string
  end
end
