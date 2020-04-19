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

ActiveRecord::Schema.define(version: 2020_01_14_094049) do

  create_table "apps", force: :cascade do |t|
    t.string "name"
    t.string "bundle_id"
    t.string "icon"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bamboo_project"
    t.string "bamboo_plan"
    t.string "description"
    t.string "slack_channel"
    t.string "jira_project_id"
    t.boolean "ipad_only"
    t.string "upload_key"
    t.index ["user_id", "created_at"], name: "index_apps_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_apps_on_user_id"
  end

  create_table "apps_users", id: false, force: :cascade do |t|
    t.integer "app_id", null: false
    t.integer "user_id", null: false
    t.index ["app_id", "user_id"], name: "index_apps_users_on_app_id_and_user_id"
    t.index ["user_id", "app_id"], name: "index_apps_users_on_user_id_and_app_id"
  end

  create_table "builds", force: :cascade do |t|
    t.string "ipa"
    t.string "manifest_url"
    t.integer "release_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bundle_id"
    t.string "bundle_version"
  end

  create_table "containers", force: :cascade do |t|
    t.string "marvel_url"
    t.string "container_path"
    t.integer "app_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_id"], name: "index_containers_on_app_id"
  end

  create_table "download_tokens", force: :cascade do |t|
    t.integer "release_id"
    t.integer "group_id"
    t.integer "user_id"
    t.boolean "isMainRelease"
    t.string "digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_download_tokens_on_group_id"
    t.index ["release_id"], name: "index_download_tokens_on_release_id"
    t.index ["user_id"], name: "index_download_tokens_on_user_id"
  end

  create_table "downloads", force: :cascade do |t|
    t.integer "release_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["release_id"], name: "index_downloads_on_release_id"
    t.index ["user_id"], name: "index_downloads_on_user_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.string "title"
    t.string "text"
    t.string "screenshot"
    t.integer "release_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.boolean "completed", default: false
    t.index ["release_id"], name: "index_feedbacks_on_release_id"
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "group_users", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_users_on_group_id"
    t.index ["user_id", "group_id"], name: "index_group_users_on_user_id_and_group_id", unique: true
    t.index ["user_id"], name: "index_group_users_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.integer "app_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "main_release_id"
    t.integer "second_release_id"
    t.index ["app_id"], name: "index_groups_on_app_id"
    t.index ["main_release_id"], name: "index_groups_on_main_release_id"
    t.index ["second_release_id"], name: "index_groups_on_second_release_id"
  end

  create_table "release_logs", force: :cascade do |t|
    t.integer "group_id"
    t.integer "release_id"
    t.boolean "is_main_release"
    t.string "changelog"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_release_logs_on_group_id"
    t.index ["release_id"], name: "index_release_logs_on_release_id"
  end

  create_table "releases", force: :cascade do |t|
    t.string "type"
    t.string "version"
    t.text "description"
    t.integer "app_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.string "container_path"
    t.boolean "hide_statusbar", default: true
    t.string "build_key"
    t.string "bamboo_branch"
    t.string "meta"
    t.index ["app_id"], name: "index_releases_on_app_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.string "activation_digest"
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.string "bamboo_token"
    t.string "bamboo_secret"
    t.string "tum_id"
    t.boolean "admin", default: false
    t.boolean "write_permissions", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
