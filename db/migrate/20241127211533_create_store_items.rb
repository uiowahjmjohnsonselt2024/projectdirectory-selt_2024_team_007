class CreateStoreItems < ActiveRecord::Migration[7.2]
  def change
    create_table :store_items do |t|
      t.string :name
      t.text :description
      t.integer :shards_cost

      t.timestamps
    end
  end
end
