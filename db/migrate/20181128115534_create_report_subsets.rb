class CreateReportSubsets < ActiveRecord::Migration[5.2]
  def change
    create_table :report_subsets do |t|
      t.string :report_id
      t.binary :compressed, :limit => 10.megabyte
      t.string :checksum
      t.string :aasm

      t.timestamps
    end
  end
end
