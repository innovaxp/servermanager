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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130418103156) do

  create_table "action_alerts", :force => true do |t|
    t.integer  "owner_id"
    t.integer  "alert_id"
    t.string   "action"
    t.text     "additional_emails"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "alerts", :force => true do |t|
    t.integer  "owner_id"
    t.text     "additional_emails"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "backup_configurations", :force => true do |t|
    t.integer  "remote_server_id"
    t.string   "db_user"
    t.string   "db_password"
    t.string   "local_folder"
    t.string   "local_folder_url"
    t.integer  "upload_service_id"
    t.boolean  "remove_local"
    t.integer  "period_number"
    t.text     "notify_to"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "period_unit"
    t.integer  "owner_id"
    t.boolean  "active"
    t.string   "name"
    t.text     "databases"
    t.string   "folder"
    t.string   "type"
  end

  create_table "backups", :force => true do |t|
    t.integer  "backup_configuration_id"
    t.string   "status"
    t.text     "meta"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.text     "tmp_files"
    t.integer  "remaining_uploads"
  end

  create_table "remote_servers", :force => true do |t|
    t.string   "description"
    t.string   "user"
    t.string   "password"
    t.string   "path"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "host"
    t.integer  "working_copy_id"
    t.integer  "owner_id"
    t.string   "type"
    t.text     "meta"
    t.integer  "root_remote_server_id"
  end

  create_table "repositories", :force => true do |t|
    t.string   "description"
    t.string   "master_location"
    t.string   "slave_location"
    t.integer  "current_version"
    t.string   "user"
    t.string   "password"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.datetime "last_sync_date"
    t.integer  "owner_id"
  end

  create_table "upload_services", :force => true do |t|
    t.string   "name"
    t.string   "location"
    t.text     "meta"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "owner_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "hashed_password"
    t.string   "salt"
    t.string   "name"
    t.string   "f_name"
    t.string   "l_name"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "rol"
    t.integer  "owner_id"
  end

  create_table "working_copies", :force => true do |t|
    t.integer  "repository_id"
    t.string   "location"
    t.string   "user"
    t.string   "password"
    t.string   "status"
    t.integer  "current_revision"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "remote_server_id"
    t.string   "type"
    t.datetime "last_update_date"
    t.text     "flags"
    t.integer  "last_revision"
    t.integer  "owner_id"
    t.string   "wc_location"
    t.boolean  "lock"
    t.string   "wc_type"
  end

end
