# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20141119010448) do

  create_table "estimation_raw_data", force: true do |t|
    t.text     "normal_sample_point_matrix"
    t.decimal  "mu"
    t.decimal  "theta"
    t.text     "inv_var_matrix"
    t.decimal  "sig2"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "math_model_runs", force: true do |t|
    t.text     "input_params"
    t.text     "result"
    t.integer  "project_settings_id"
    t.boolean  "show"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "math_model_runs", ["project_settings_id"], name: "index_math_model_runs_on_project_settings_id"

  create_table "powder_data_quality_metrics", force: true do |t|
    t.decimal  "value"
    t.string   "type"
    t.integer  "math_model_run_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "powder_data_quality_metrics", ["math_model_run_id"], name: "index_powder_data_quality_metrics_on_math_model_run_id"

  create_table "project_executables", force: true do |t|
    t.string   "command"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_parameter_spaces", force: true do |t|
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_settings", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "accuracy"
    t.integer  "executable_id"
    t.integer  "parameter_space_id"
    t.string   "adapter"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_settings", ["executable_id"], name: "index_project_settings_on_executable_id"
  add_index "project_settings", ["parameter_space_id"], name: "index_project_settings_on_parameter_space_id"

end
