class LandingController < ApplicationController
  def index
    @games = @current_user.games.order(created_at: :desc)
  end
end