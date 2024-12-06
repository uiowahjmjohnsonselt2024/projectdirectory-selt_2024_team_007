class AddJoinCodeToGames < ActiveRecord::Migration[7.2]
  def change
    add_column :games, :join_code, :string
    add_index :games, :join_code, unique: true
  end
end