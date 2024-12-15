class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :item_name
      t.string :item_type
      t.integer :item_cost
      t.datetime :purchased_at

      t.timestamps
    end
  end
end
