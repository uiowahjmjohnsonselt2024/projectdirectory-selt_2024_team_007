
class GamesController < ApplicationController
  before_action :set_current_user  # Ensure user is authenticated
  before_action :set_game, only: [:show, :invite_friends, :chat]
  before_action :authorize_game_user, only: [:chat]  # Ensure user belongs to the game

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

  def dm_response
    user_message = params[:message] # Assume the user sends a message in the params
    dm_service = GptDmService.new
    response = dm_service.generate_dm_response(user_message)

    render json: { response: response }
  end

  # GET /games/:id
  def show
    @game_users = @game.game_users.includes(:user)
    @tiles = @game.tiles.order(:x_coordinate, :y_coordinate)
  end

  # POST /games/:id/chat
  def chat
    user_message = params[:message]
    gpt_service = GptDmService.new
    gpt_response = gpt_service.generate_dm_response(user_message)

    # Broadcast the GPT response to all connected clients for this game
    ChatChannel.broadcast_to(@game, {
      user: @current_user.name,
      message: user_message,
      gpt_response: gpt_response
    })

    # Respond with a simple success (no need to re-render or return JSON)
    head :ok
  rescue => e
    # Flash error message on failure and redirect back to the same page
    flash[:alert] = "Failed to process your message: #{e.message}"
    head :unprocessable_entity
  end


  def invite_friends
    friend_ids = params[:friend_ids] || []
    friend_ids = friend_ids.map(&:to_i)

    # Limit to 3 friends
    if friend_ids.size > 3
      flash[:alert] = 'You can invite up to 3 friends.'
      @game_with_error_id = @game.id
      redirect_to root_path and return
    end

    # Check if total players exceed 4
    total_players = @game.users.count + friend_ids.size
    if total_players > 4
      flash[:alert] = 'Total players in a game cannot exceed 4.'
      @game_with_error_id = @game.id
      redirect_to root_path and return
    end

    # Ensure selected friends are actually friends of the user
    current_user_friend_ids = (@current_user.friends + @current_user.inverse_friends).map(&:id)
    friend_ids = friend_ids & current_user_friend_ids

    # Remove friends already in the game
    existing_user_ids = @game.users.pluck(:id)
    new_friend_ids = friend_ids - existing_user_ids

    # Add friends to the game
    new_friend_ids.each do |friend_id|
      friend = User.find(friend_id)
      @game.game_users.create(user: friend, health: 100)
    end

    flash[:notice] = 'Friends successfully added to the game.'
    redirect_to root_path
  end

  private

  # Ensure the user is part of the game
  def authorize_game_user
    unless @game.game_users.exists?(user_id: @current_user.id)
      render json: { error: "You are not authorized to chat in this game." }, status: :forbidden
    end
  end

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

  def ensure_owner
    unless @game.owner == @current_user
      flash[:alert] = 'You are not authorized to add friends to this game.'
      redirect_to root_path
    end
  end
end
