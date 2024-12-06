class CreateGameUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :game_users do |t|
      t.references :game, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer    :health
      t.text       :equipment
      t.integer    :current_tile_id

      t.timestamps
    end

    add_index :game_users, [:game_id, :user_id], unique: true
    add_index :game_users, :current_tile_id
    add_foreign_key :game_users, :tiles, column: :current_tile_id
  end
end