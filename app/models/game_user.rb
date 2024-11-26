class GameUser < ApplicationRecord
  belongs_to :game
  belongs_to :user
  belongs_to :current_tile, class_name: 'Tile', foreign_key: 'current_tile_id', optional: true

  # Validations
  validates :health, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
