class CreateUserStoreItems < ActiveRecord::Migration[7.2]
  def change
    create_table :user_store_items do |t|
      t.integer :user_id, null: false
      t.integer :store_item_id, null: false

    end

    add_index :user_store_items, :user_id
    add_index :user_store_items, :store_item_id
    add_index :user_store_items, [:user_id, :store_item_id], unique: true

    add_foreign_key :user_store_items, :users
    add_foreign_key :user_store_items, :store_items
  end
end
