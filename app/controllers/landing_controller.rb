class LandingController < ApplicationController
  def index
    @games = @current_user.games.includes(:game_users).order(created_at: :desc)
    @friends = @current_user.friends
  end
end