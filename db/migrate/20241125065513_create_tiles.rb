class CreateTiles < ActiveRecord::Migration[7.2]
  def change
    create_table :tiles do |t|
      t.references :game, null: false, foreign_key: true
      t.integer    :x_coordinate
      t.integer    :y_coordinate
      t.string     :tile_type
      t.string     :image_reference

      t.timestamps
    end

    add_index :tiles, [:game_id, :x_coordinate, :y_coordinate], unique: true
  end
end