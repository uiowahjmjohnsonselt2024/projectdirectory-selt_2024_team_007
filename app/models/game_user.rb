class GameUser < ApplicationRecord
  belongs_to :game
  belongs_to :user
  belongs_to :current_tile, class_name: 'Tile', foreign_key: 'current_tile_id', optional: true

  # Validations
  validates :health, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :max_players_limit, on: :create

  private

  def max_players_limit
    if game.game_users.count >= 4
      errors.add(:base, 'Cannot have more than 4 players in a game.')
    end
  end
end
