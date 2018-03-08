class AddClientIdColumn < ActiveRecord::Migration[5.1]
  def up
    drop_table :reports

    create_table :reports do |t|
      t.string :report_name, default: "Dataset Report"
      t.string :report_id
      t.string :client_id, null: false
      t.string :provider_id, null: false
      t.string :release, default: "RD1"
      t.string :created
      t.string :created_by
      t.json   :report_filters
      t.json   :report_attributes
      t.json   :report_datasets
      t.string :exceptions

      t.timestamps
    end
  end

  def down
    drop_table :reports

    create_table "report".pluralize.to_sym, id: false do |t|
      t.string :id
      t.string :report_name
      t.string :report_id
      t.string :release
      t.string :created
      t.string :created_by
      t.json   :report_filters
      t.json   :report_attributes
      t.json   :report_datasets
      t.string :exceptions

      t.timestamps
    end
  end
end
