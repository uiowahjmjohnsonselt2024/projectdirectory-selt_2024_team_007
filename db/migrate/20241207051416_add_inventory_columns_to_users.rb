class AddInventoryColumnsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :teleport, :integer, default: 0, null: false
    add_column :users, :health_potion, :integer, default: 0, null: false
    add_column :users, :resurrection_token, :integer, default: 0, null: false
  end
end
