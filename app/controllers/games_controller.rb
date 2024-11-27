class GamesController < ApplicationController
  before_action :set_current_user  # Ensure user is authenticated
  before_action :set_game, only: [:show]

  # POST /games
  def create
    @game = Game.new(game_params)
    @game.owner = @current_user
    @game.current_turn_user = @current_user

    if @game.save
      # Add the creator to the game_users
      @game.game_users.create(user: @current_user, health: 100)

      redirect_to @game, notice: 'Game was successfully created.'
    else
      flash[:alert] = @game.errors.full_messages.to_sentence
      redirect_to root_path
    end
  end

  # POST /games/join
  def join
    @game = Game.find_by(join_code: params[:join_code].strip.upcase)

    if @game
      if @game.game_users.exists?(user: @current_user)
        redirect_to @game, notice: 'You have already joined this game.'
      else
        @game.game_users.create(user: @current_user, health: 100)
        redirect_to @game, notice: 'You have successfully joined the game.'
      end
    else
      flash[:alert] = 'Invalid join code.'
      redirect_to root_path
    end
  end

  # GET /games/:id
  def show
    @game_users = @game.game_users.includes(:user)
    @tiles = @game.tiles.order(:x_coordinate, :y_coordinate)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_game
    @game = Game.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = 'Game not found.'
    redirect_to root_path
  end

  # Only allow a list of trusted parameters through.
  def game_params
    params.require(:game).permit(:name, :join_code)
  end
end
