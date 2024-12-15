# *********************************************************************
# This file was crafted using assistance from Generative AI Tools.
#   Open AI's ChatGPT o1, 4o, and 4o-mini models were used from November
# 4th 2024 to December 15, 2024. The AI Generated code was not
# sufficient or functional outright nor was it copied at face value.
# Using our knowledge of software engineering, ruby, rails, web
# development, and the constraints of our customer, SELT Team 007
# (Cody Alison, Yusuf Halim, Ziad Hasabrabu, Bradley Johnson,
# and Sheng Wang) used GAITs responsibly; verifying that each line made
# sense in the context of the app, conformed to the overall design,
# and was testable. We maintained a strict peer review process before
# any code changes were merged into the development or production
# branches. All code was tested with BDD and TDD tests as well as
# empirically tested with local run servers and Heroku deployments to
# ensure compatibility.
# *******************************************************************
class GameUser < ApplicationRecord
  belongs_to :game
  belongs_to :user
  belongs_to :current_tile, class_name: 'Tile', foreign_key: 'current_tile_id', optional: true

  # Validations
  validates :health, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :max_players_limit, on: :create, if: -> { game.present? }

  private

  def max_players_limit
    if game.game_users.count >= 4
      errors.add(:base, 'Cannot have more than 4 players in a game.')
    end
  end
end
