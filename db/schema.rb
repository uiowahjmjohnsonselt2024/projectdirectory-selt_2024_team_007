# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_12_14_172634) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "billing_methods", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "card_number"
    t.string "card_holder_name"
    t.date "expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cvv", null: false
    t.index ["user_id"], name: "index_billing_methods_on_user_id"
  end

  create_table "friendships", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "friend_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "friend_id"], name: "index_friendships_on_user_id_and_friend_id", unique: true
  end

  create_table "game_users", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "user_id", null: false
    t.integer "health"
    t.text "equipment"
    t.integer "current_tile_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "quests", default: []
    t.index ["current_tile_id"], name: "index_game_users_on_current_tile_id"
    t.index ["game_id", "user_id"], name: "index_game_users_on_game_id_and_user_id", unique: true
    t.index ["game_id"], name: "index_game_users_on_game_id"
    t.index ["user_id"], name: "index_game_users_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "name"
    t.text "context"
    t.integer "current_turn_user_id"
    t.integer "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "join_code"
    t.string "map_size", default: "6x6", null: false
    t.text "quests"
    t.string "genre"
    t.string "setting"
    t.text "chat_image_url"
    t.index ["current_turn_user_id"], name: "index_games_on_current_turn_user_id"
    t.index ["join_code"], name: "index_games_on_join_code", unique: true
    t.index ["owner_id"], name: "index_games_on_owner_id"
  end

  create_table "store_items", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "shards_cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "item_id"
    t.index ["item_id"], name: "index_store_items_on_item_id", unique: true
  end

  create_table "tiles", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "x_coordinate"
    t.integer "y_coordinate"
    t.string "tile_type"
    t.string "image_reference"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "x_coordinate", "y_coordinate"], name: "index_tiles_on_game_id_and_x_coordinate_and_y_coordinate", unique: true
    t.index ["game_id"], name: "index_tiles_on_game_id"
  end

  create_table "user_store_items", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "store_item_id", null: false
    t.index ["store_item_id"], name: "index_user_store_items_on_store_item_id"
    t.index ["user_id", "store_item_id"], name: "index_user_store_items_on_user_id_and_store_item_id", unique: true
    t.index ["user_id"], name: "index_user_store_items_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "password_digest", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "session_token"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.string "uid"
    t.integer "shards_balance", default: 0, null: false
    t.integer "teleport", default: 0, null: false
    t.integer "health_potion", default: 0, null: false
    t.integer "resurrection_token", default: 0, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["session_token"], name: "index_users_on_session_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "billing_methods", "users"
  add_foreign_key "friendships", "users"
  add_foreign_key "friendships", "users", column: "friend_id"
  add_foreign_key "game_users", "games"
  add_foreign_key "game_users", "tiles", column: "current_tile_id"
  add_foreign_key "game_users", "users"
  add_foreign_key "games", "users", column: "current_turn_user_id"
  add_foreign_key "games", "users", column: "owner_id"
  add_foreign_key "tiles", "games"
  add_foreign_key "user_store_items", "store_items"
  add_foreign_key "user_store_items", "users"
end
