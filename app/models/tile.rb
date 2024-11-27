class Tile < ApplicationRecord
  belongs_to :game
  has_many :game_users, foreign_key: 'current_tile_id'

  # Validations
  validates :x_coordinate, :y_coordinate,
            presence: true,
            numericality: { only_integer: true }
  validates :tile_type, presence: true
  validates :x_coordinate, uniqueness: { scope: [:game_id, :y_coordinate], message: "and Y coordinate combination must be unique within a game" }
end
