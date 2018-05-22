# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180522095206) do

  create_table "error_models", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "code"
    t.string "severity"
    t.string "message"
    t.string "help_url"
    t.string "cata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "publishers", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "publisher_name"
    t.string "publisher_id"
    t.string "path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "report_types", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "report_id"
    t.string "release"
    t.string "report_description"
    t.string "path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reports", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "report_name", default: "Dataset Report"
    t.string "report_id"
    t.string "client_id", null: false
    t.string "provider_id", null: false
    t.string "release", default: "RD1"
    t.string "created"
    t.string "created_by"
    t.json "report_filters"
    t.json "report_attributes"
    t.json "report_datasets"
    t.string "exceptions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "year"
    t.string "month"
    t.string "uid"
    t.json "reporting_period"
    t.index ["created_by", "month", "year"], name: "index_reports_on_multiple_columns", unique: true
  end

  create_table "status_alerts", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "date_time"
    t.string "alert"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "statuses", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "description"
    t.boolean "service_active"
    t.string "registry_url"
    t.string "note"
    t.string "alerts"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
