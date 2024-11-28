class GamesController < ApplicationController
  before_action :set_current_user  # Ensure user is authenticated
  before_action :set_game, only: [:show]

  # POST /games
  def create
    if @current_user.shards_balance >= 500
      @game = Game.new(game_params)
      @game.owner = @current_user
      @game.current_turn_user = @current_user

      if @game.save
        @current_user.update_column(:shards_balance, @current_user.shards_balance - 500)
        @game.game_users.create(user: @current_user, health: 100)
        redirect_to @game, notice: 'Game was successfully created.'
      else
        # Render the landing page with errors
        @games = @current_user.games
        flash[:danger] = "An error occurred."
        render 'landing/index', status: :unprocessable_entity
      end
    else
      @games = @current_user.games
      flash[:error] = "Insufficient Shards Balance"
      redirect_to landing_path
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
    params.require(:game).permit(:name, :join_code, :map_size)
  end  
end
