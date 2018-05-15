class AddReportingPeriodToReports < ActiveRecord::Migration[5.1]
  def change
    add_column :reports, :reporting_period, :json
  end
end
