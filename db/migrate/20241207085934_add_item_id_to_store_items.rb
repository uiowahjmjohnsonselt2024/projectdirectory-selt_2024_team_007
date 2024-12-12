class AddItemIdToStoreItems < ActiveRecord::Migration[7.2]
  def change
    add_column :store_items, :item_id, :integer
    add_index :store_items, :item_id, unique: true
  end
end
