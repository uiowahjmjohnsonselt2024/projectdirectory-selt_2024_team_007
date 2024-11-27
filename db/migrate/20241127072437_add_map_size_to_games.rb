class AddMapSizeToGames < ActiveRecord::Migration[7.2]
  def change
    add_column :games, :map_size, :string, null: false, default: '6x6'
  end
end

