
class GamesController < ApplicationController
  before_action :set_current_user  # Ensure user is authenticated
  before_action :set_game, only: [:show, :invite_friends, :chat, :leave]
  before_action :authorize_game_user, only: [:chat]  # Ensure user belongs to the game

  # POST /games
  def create
    if @current_user.shards_balance >= 40
      @game = Game.new(game_params)
      @game.owner = @current_user
      @game.current_turn_user = @current_user

      # If genre/setting not provided, either set defaults or generate via GPT
      if @game.genre.blank?
        # Example default or GPT generationer here:
        @game.genre = "Fantasy"
      end

      gpt_service = GptDmService.new
      begin
        # Attempt to generate a setting from GPT based on the chosen genre
        generated_setting = gpt_service.generate_setting(@game.genre)
        # If GPT returns nil or empty, use a fallback
        @game.setting = generated_setting.presence || default_setting_for_genre(@game.genre)
      rescue => e
        Rails.logger.error("GPT Setting Generation Failed: #{e.message}")
        # Use a genre-relevant fallback if GPT fails
        @game.setting = default_setting_for_genre(@game.genre)
      end

      # Set a default internal image URL if none is provided
      @game.chat_image_url ||= "login_register_background.jpg"

      if @game.save
        @current_user.update_column(:shards_balance, @current_user.shards_balance - 40)
        @game.game_users.create(user: @current_user, health: 100)
        @game.update(context: "[]") if @game.context.blank?
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

  def move
    @game = Game.find(params[:id])
    @game_user = @game.game_users.find_by(user: @current_user)
    @tile = @game.tiles.find_by(x_coordinate: params[:x], y_coordinate: params[:y])
  
    # Get current position
    current_tile = @game_user.current_tile
    
    # Check if move is to an adjacent tile
    is_adjacent = if current_tile
      (current_tile.x_coordinate - @tile.x_coordinate).abs <= 1 &&
      (current_tile.y_coordinate - @tile.y_coordinate).abs <= 1
    else
      true # Allow first move to any tile
    end
  
    if is_adjacent || @current_user.teleport > 0
      if @tile && @game_user.update(current_tile: @tile)
        # Only decrement teleport if using non-adjacent movement
        @current_user.decrement!(:teleport) unless is_adjacent
        
        ActionCable.server.broadcast "presence_channel_#{@game.id}", {
          user: @current_user.name,
          status: 'moved',
          x: @tile.x_coordinate,
          y: @tile.y_coordinate
        }
        head :ok
      else
        head :unprocessable_entity
      end
    else
      flash[:alert] = 'Can only move to adjacent tiles without teleport'
      redirect_to game_path(@game)
    end
  end
  

  def map
    @game = Game.find(params[:id])
    @tiles = @game.tiles.order(:x_coordinate, :y_coordinate)
    @game_users = @game.game_users.includes(:user, :current_tile)
    render partial: 'map', locals: { game: @game, tiles: @tiles, game_users: @game_users }
  end
  

  def leave
    game_user = @game.game_users.find_by(user: @current_user)
    if game_user
      game_user.destroy
      flash[:notice] = 'You have successfully left the game.'
    else
      flash[:alert] = 'You are not part of this game.'
    end
    redirect_to root_path
  end

  # GET /games/:id
  def show
    @game_users = @game.game_users.includes(:user)
    @tiles = @game.tiles.order(:x_coordinate, :y_coordinate)
    current_game_user = @game_users.find_by(user: @current_user)
    @equipment_items = fetch_equipment(current_game_user)

    # Parse the game.context to find the last assistant message
    messages = []
    if @game.context.present?
      begin
        messages = JSON.parse(@game.context)
      rescue JSON::ParserError
        messages = []
      end
    end

    # Find the last assistant message
    @last_assistant_message = messages.reverse.find { |m| m["role"] == "assistant" }&.dig("content")

    # Get the most recent image URL from the game record
    @last_chat_image_url = @game.chat_image_url
  end

  # POST /games/:id/chat
  def chat
    # from text box
    user_message = params[:message]

    # Load current conversation from @game.context
    current_messages_from_db_without_game_state = []
    if @game.context.present?
      begin
        current_messages_from_db_without_game_state = JSON.parse(@game.context)
      rescue JSON::ParserError
        current_messages_from_db_without_game_state = []
      end
    end

    # Append the user message (local storage)
    current_messages_from_db_without_game_state << { "role" => "user", "content" => user_message }

    # Check if we need to summarize older messages
    # Let's say we consider anything above 40 messages is too big.
    if current_messages_from_db_without_game_state.size > 15
      flash[:notice] = "The conversation history has been summarized to improve performance and manage token usage."
      gpt_service = GptDmService.new
      summary = gpt_service.summarize_conversation(JSON.dump(current_messages_from_db_without_game_state))
      # Replace all but the last few messages with the summary
      # Let's keep the last 5 messages for more recent context, and replace the rest
      recent_messages = current_messages_from_db_without_game_state.last(5)
      current_messages_from_db_without_game_state = [{"role" => "assistant", "content" => summary}] + recent_messages
    end

    # COPY IT ALL separate so we can save it in a smaller form without the game state for history’s sake
    message_to_send_to_gpt_as_user_msg_with_game_state = current_messages_from_db_without_game_state.dup

    # Build complex game state prompt
    players = @game.game_users.includes(:user).map do |game_user|
      {
        id: game_user.user_id,
        name: game_user.user.name,
        position: fetch_player_position(game_user), # Helper to determine tile position
        inventory: fetch_inventory(game_user.user_id), # Helper to pull items
        equipment: fetch_equipment(game_user), # User's equipment
        health: game_user.health || 100,
        status: "active" # Adjust status dynamically as needed
      }
    end

    # Construct map details
    map_tiles = @game.tiles.map do |tile|
      {
        x: tile.x_coordinate,
        y: tile.y_coordinate,
        type: tile.tile_type,
        description: tile.image_reference || "No description provided"
      }
    end

    # Construct the game state
    game_state = {
      game_state: {
        # TODO Add dynamic setting/genre on game creation
        genre: @game.genre || "Fantasy",
        setting: @game.setting || "A vast kingdom at war with neighboring realms",
        players: players,
        map: {
          size: {
            width: @game.map_size.split("x").first.to_i,
            height: @game.map_size.split("x").last.to_i
          },
          tiles: map_tiles
        },
        quests: fetch_active_quests(@game), # Helper to fetch quests associated with the game
        rules: {
          inventory_management: "Players may only use items listed in their inventory.",
          movement: "Players can only move to adjacent tiles unless otherwise instructed.",
          fairness: "Player actions must adhere to the rules."
        }
      },
      user_response: user_message # Explicitly include user's message in input
    }

    # Convert to JSON string
    json_string = JSON.dump(game_state)

    # Append the user message
    message_to_send_to_gpt_as_user_msg_with_game_state << { "role" => "user", "content" => json_string } # We give GPT All this stuff.

    # GPT Chat portion
    gpt_service = GptDmService.new
    gpt_response = gpt_service.generate_dm_response(message_to_send_to_gpt_as_user_msg_with_game_state, @game.id, @current_user.id, game_state)

    # Append the assistant's response to the conversation
    current_messages_from_db_without_game_state << { "role" => "assistant", "content" => gpt_response }

    # Store updated conversation back to the database, minimize db calls by doing this once at the end.
    @game.update!(context: JSON.dump(current_messages_from_db_without_game_state))

    # Fetch current user's position and tile description
    current_user_game_user = @game.game_users.find_by(user: @current_user)
    current_user_tile = Tile.find_by(id: current_user_game_user&.current_tile_id)
    tile_description = current_user_tile&.image_reference || "No specific details are available for this tile."

    # Enhanced player description with prompt engineering
    player_description = <<~PROMPT
This is a description of the player and their surroundings for generating a Dungeons & Dragons-style fantasy-themed image:
- Player Name: #{@current_user.name}
- Position: #{current_user_tile&.x_coordinate}, #{current_user_tile&.y_coordinate}
- Tile Description: #{tile_description}
    PROMPT


    # Now we want to get an image and include it in the broadcase
    # Enhance the image prompt with tile description and player description
    image_prompt = <<~PROMPT
Create a detailed Dungeons & Dragons fantasy-themed illustration based on the following:
1. The player's interaction: "#{user_message} #{gpt_response}".
2. Current player's information:
    #{player_description}.
The illustration should depict a scene matching the player's position and the tile's description in the game world.
PROMPT

    # Dont want image prompts to be too big and fail.
    refined_image_prompt = gpt_service.generate_image_prompt(image_prompt)

    # Generate image using the new GptImgService
    image_response = gpt_service.generate_image(refined_image_prompt)

    Rails.logger.info("Generated image URL: #{image_response.inspect}")
    puts "Generated image URL: #{image_response.inspect}"

    # Save the generated image URL to the games table
    @game.update!(chat_image_url: image_response)

    # After GPT response and after updating the @game context
    active_user_ids = $redis.smembers("active_users_#{@game.id}")
    active_user_ids.map!(&:to_i)

    active_users = User.where(id: active_user_ids)
    if active_users.present?
      current_index = active_users.index(@game.current_turn_user) || -1
      next_user = active_users[(current_index + 1) % active_users.length]
      @game.update(current_turn_user: next_user)
    end

    # Broadcast the updated current turn
    ActionCable.server.broadcast("presence_channel_#{@game.id}", {
      action: 'update_turn',
      current_turn_user_id: @game.current_turn_user.id,
      current_turn_user_name: @game.current_turn_user.name
    })
    
    @game.reload # Ensure we have the latest data from the database

    # Re-fetch players with updated equipment and health
    updated_players = @game.game_users.includes(:user).map do |game_user|
      user = game_user.user
      {
        id: game_user.user_id,
        name: game_user.user.name,
        position: fetch_player_position(game_user),
        inventory: fetch_inventory(game_user.user_id),
        equipment: fetch_equipment(game_user),
        health: game_user.health || 100,
        resurrection_token: user.resurrection_token || 0, # Include resurrection token count
        health_potion: user.health_potion || 0,         # Include health potion count
        teleport_token: user.teleport || 0,             # Include teleport token count
        status: "active"
      }
    end

    # Broadcast the GPT response to all connected clients for this game
    ChatChannel.broadcast_to(@game, {
      user: @current_user.name,
      message: user_message,
      gpt_response: gpt_response,
      gpt_img_resp: image_response,
      image_prompt: refined_image_prompt,
      updated_players: updated_players
    })

    # Respond with a simple success (no need to re-render or return JSON)
    head :ok
  rescue => e
    # Log the error
    Rails.logger.error("Chat error for Game ID #{@game.id}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n")) # Log backtrace for detailed debugging

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
    params.require(:game).permit(:name, :join_code, :map_size, :genre)
  end

  def ensure_owner
    unless @game.owner == @current_user
      flash[:alert] = 'You are not authorized to add friends to this game.'
      redirect_to root_path
    end
  end

  def fetch_player_position(game_user)
    tile = Tile.find_by(id: game_user.current_tile_id)
    { x: tile&.x_coordinate || 0, y: tile&.y_coordinate || 0 }
  end

  def fetch_inventory(user_id)
    user = User.find(user_id)

    # Fetch non-consumable store items with descriptions
    store_items = user.store_items.map do |item|
      { name: item.name, description: item.description }
    end

    # Fetch consumable items with descriptions
    consumables = consumable_items(user)

    # Combine store items and consumables
    store_items + consumables
  end



  def consumable_items(user)
    consumables = []

    consumables << { name: "teleport", description: "Allows the player to teleport to any tile on the map." } if user.teleport.positive?
    consumables << { name: "health_potion", description: "Restores 50 health points when consumed." } if user.health_potion.positive?
    consumables << { name: "resurrection_token", description: "Revives the player upon death with full health." } if user.resurrection_token.positive?

    consumables
  end

  def fetch_equipment(game_user)
    equipment = game_user.equipment || "" # Assuming `equipment` is a string column on the `game_users` table.

    # Parse the equipment string into a JSON object if it exists
    JSON.parse(equipment, symbolize_names: true) rescue []
  end

  def fetch_active_quests(game)
    game.quests || "[]" # Return the quests string or an empty array as a string if no quests are set
  end

  # Provide a default setting for each genre as a fallback if GPT fails
  def default_setting_for_genre(genre)
    case genre
    when "High fantasy"
      "A lush and magical world full of mystical creatures and ancient forests."
    when "Realistic Medieval"
      "A gritty medieval kingdom where lords and peasants struggle to survive amidst constant war."
    when "American West"
      "A rugged frontier of endless plains, dusty towns, and opportunistic outlaws."
    when "Nuclear Apocalypse"
      "A ruined landscape of blasted cities, scarce resources, and lurking mutants."
    when "Zombie Apocalypse"
      "A devastated world overrun by the undead, where survivors cling to life in fortified enclaves."
    else
      # Fallback for unexpected or default genre
      "A vast kingdom at war with neighboring realms"
    end
  end

end
