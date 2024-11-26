class CreateGames < ActiveRecord::Migration[7.2]
  def change
    create_table :games do |t|
      t.string  :name
      t.text    :context
      t.integer :current_turn_user_id
      t.integer :owner_id

      t.timestamps
    end

    add_index :games, :current_turn_user_id
    add_index :games, :owner_id
    add_foreign_key :games, :users, column: :current_turn_user_id
    add_foreign_key :games, :users, column: :owner_id
  end
end