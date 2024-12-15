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
class GptDmService
  def initialize(client = OpenAI::Client.new)
    @client = client
  end

  def generate_dm_response(messages_array, game_id, user_id, game_state)
    @game = Game.find(game_id) # Ensure @game is accessible here
    @user_id = user_id
    system_prompt = <<~PROMPT
**System Prompt:**

You are a Dungeon Master for a dynamic, imaginative role-playing game. Your role is to:  
- Craft an engaging story filled with thrilling encounters, rich lore, and unexpected twists.  
- Adapt to any genre or setting chosen by the players.  
- Provide vivid descriptions, balanced challenges, and fair outcomes for player actions.  
- Enforce game rules and reflect all changes to the game state by calling the provided tool functions.  
- At the end of processing each turn or action, you **MUST** call the `dungeon_master_text_response` function exactly once, providing the narrative text. Not calling it will result in no player-facing output.

**Key Rules and Instructions:**

0. **At the end of every turn or action:**  
   **Call `dungeon_master_text_response`** with a narrative text conclusion. This is mandatory.

1.) **Update Players Requirement:**
  - When calling `update_players`, you must include **all fields for all players** in the game, even if certain fields have not changed. Treat `update_players` as a **set operation**, where you provide the complete state of each player. For example, if a player’s `health` remains 75, include `health: 75` in the `update_players` call for that player. If no changes occur for a player, pass their state exactly as it was. This ensures the entire game state is synchronized correctly.

2. **Consumable Items (Health Potion, Teleport Token, Resurrection Token):**  
   - These items are in the player’s inventory and can be used if available.  
   - If a player uses one this turn, set its corresponding `consumables` boolean to `true` in `update_players`.
   - If not used, set its corresponding `consumables` boolean to `false`.
   - Always mention by name which of these items were used or not used when calling `update_players`.

   Example:  
   - If a player uses a health potion, then `health_potion` = `true`. If not, `health_potion` = `false`.  
   - Same logic applies for `teleport` and `resurrection_token`.

   Default if no items are used:  
   - `health_potion` = `false`  
   - `teleport` = `false`  
   - `resurrection_token` = `false`

3. **Inventory and Equipment Distinction:**  
   - Inventory = Premium items (e.g., teleport tokens, health potions, resurrection tokens). Cannot be added or removed except by their intended consumption.  
   - Equipment = Regular non-premium items found or obtained in the world.  
     - Players can pick up non-premium items and have them added to their `equipment`.  
     - They can discard equipment, which you can remove from `equipment`.

4. **Movement Rules:**  
   - Players move on a grid. Adjacent moves are free unless story constraints prevent movement.  
   - Moving to a non-adjacent tile requires using a teleport token (`teleport` = `true`).  
   - If a player tries to move non-adjacently without a teleport token, deny the move with a lore reason.  
   - If story constraints prevent movement (e.g., locked doors, traps), deny the move unless a teleport token is used.

5. **Health and Resurrection:**  
   - Health potion restores half max health (assume max health = 100, so heals 50).  
   - If a player is at 0 health, they cannot act unless revived with a resurrection token (`resurrection_token` = `true`).

6. **Quest Integration:**  
   - Incorporate quests as subtle narrative arcs.  
   - If quest data is too large, summarize relevant parts.

7. **Updating State:**  
   After processing actions, call the appropriate functions with updated states:  
   - `update_map_state` if the map changes.  
   - `update_quests` if quests update.  
   - `update_players` if players move, change equipment, health, or use consumables.  
   - Finally, `dungeon_master_text_response` with the narrative text.

8. **Denying Invalid Actions:**  
   - Deny usage of inventory items not owned by the player. Provide a narrative reason.  
   - Deny movement that doesn’t follow rules. Provide a narrative reason.  
   - Deny attempts to add or remove premium items (inventory) unless they are being properly consumed.

**Remember:**  
- The last tool call must be `dungeon_master_text_response` with a narrative conclusion.  
- If no action occurred, still provide a narrative response calling `dungeon_master_text_response`.

    PROMPT


    messages_array = [{ "role" => "system", "content" => system_prompt }] + messages_array

    # Convert keys to symbols for the OpenAI API (if needed)
    messages = messages_array.map { |m| { role: m["role"], content: m["content"] } }

    # Define the tools (functions) that the assistant can call
    tools = define_tools

    response = @client.chat(
      parameters: {
        model: "gpt-4o",
        messages: messages,
        tools: tools,
        tool_choice: "required", # The assistant must choose a tool if it wants to make updates
        temperature: 0.7
      }
    )

    # Parse the response
    message = response.dig("choices", 0, "message")
    dungeon_master_text_response_to_return = "No response generated by GPT."

    # If the assistant calls tools (functions), handle them here
    if message["role"] == "assistant" && message["tool_calls"]
      # The assistant may call multiple tools. Let's handle them one by one.
      message["tool_calls"].each do |tool_call|
        tool_call_id = tool_call.dig("id")
        function_name = tool_call.dig("function", "name")
        function_args = JSON.parse(tool_call.dig("function", "arguments"), { symbolize_names: true })

        # Execute the function call on the server side
        function_response = case function_name
        when "update_map_state"
          handle_update_map_state(function_args)
        when "update_quests"
          handle_update_quests(function_args)
        when "update_players"
          handle_update_players(function_args)
        when "dungeon_master_text_response"
          # Just a DM response, maybe save it or broadcast it
          dungeon_master_text_response_to_return = function_args[:content]
          "DM response noted."
        else
          "Unknown function."
        end
      end
    else
     # No tool calls, just return the content
     "ERROR! GPT failed to call functions to update game state!"
    end

    # Ensure we retrieve dungeon_master_text_response before falling back
    if dungeon_master_text_response_to_return == "No response generated by GPT."
      Rails.logger.warn("No DM response was directly provided. Checking for a missed response.")
      dungeon_master_text_response_to_return = verify_and_fallback_response(message, messages_array)
    end

    # When done calling functions, return DM string so it can be broadcast
    #
    dungeon_master_text_response_to_return
    rescue => e
      Rails.logger.error("GPT API Error: #{e.message}")
      "An error occurred while generating the response."
  end

  def generate_image_prompt(context)
    # System prompt for refining the image prompt
    system_prompt = <<~PROMPT
    You are a creative assistant specialized in generating descriptive prompts for fantasy-themed illustrations. 
    Your task is to distill the key elements from the given context to create a concise and vivid prompt 
    for an AI image generation model. Prioritize visual elements, especially actions or settings, 
    while keeping the prompt under 900 characters.

    # Instructions:
    - Focus on the most visually striking actions, settings, and details.
    - Highlight key interactions described in the response.
    - If multiple actions are described, creatively combine them to depict a coherent and engaging scene.
    - Ensure the prompt is optimized for creating a single, dynamic fantasy-themed image.
    - Try not to add text unless it is part of the scene. The point is to convey a beautiful coherent scene. 
    PROMPT

    # Prepare messages for GPT call
    messages = [
      { role: "system", content: system_prompt },
      { role: "user", content: "Context: #{context}" },
    ]

    # Call GPT API
    response = @client.chat(
      parameters: {
        model: "gpt-4",
        messages: messages,
        temperature: 0.7
      }
    )

    # Extract the refined image prompt
    response.dig("choices", 0, "message", "content").strip
  rescue => e
    Rails.logger.error("Image Prompt Refinement Error: #{e.message}")
    "Fantasy-themed illustration of a dynamic Dungeons & Dragons scene."
  end


  # New method to generate a single small (256x256) DALL·E 3 image
  def generate_image(prompt)
    response = @client.images.generate(
      parameters: {
        prompt: prompt,
        model: "dall-e-3",
        quality: "standard",
        size: "1024x1024" # Smallest square size
      }
    )


    response.dig("data", 0, "url")
  rescue => e
    Rails.logger.error("Image Generation Error: #{e.message}")
    nil
  end


  def summarize_conversation(messages)
    # We will take all messages and ask GPT to summarize them into a concise form.
    # Instructions: produce a short summary highlighting key narrative points, player actions,
    # and any important story developments, without extraneous details.

    # We only need the content from these messages. We can ignore system and developer role
    # instructions since the summary should focus on user/assistant narrative and actions.

    system_prompt = <<~PROMPT
You are a summarizing assistant. The user has a long D&D style conversation history with a Dungeon Master (assistant).
Your task is to produce a concise summary of the conversation so far, focusing on:
- Major plot points
- Important player actions or decisions
- Notable outcomes or changes in the game state (if mentioned)
- Key challenges or conflicts introduced
- Any significant NPCs or locations mentioned repeatedly

The summary should be as short as possible, ideally under 500 characters, while preserving essential context.
Do not include formatting like bullet points, just a compact paragraph or two.

Keep it factual and do not add new information. This summary will be used to refresh the assistant
on what has happened so far without reading the entire transcript.
    PROMPT

    response = @client.chat(
      parameters: {
        model: "gpt-4",
        messages: [
          { role: "system", content: system_prompt },
          { role: "user", content: messages }
        ],
        temperature: 0.5
      }
    )

    summary_text = response.dig("choices", 0, "message", "content")
    summary_text.strip
  rescue => e
    Rails.logger.error("Error summarizing conversation: #{e.message}")
    # If error, return a fallback summary
    "A brief summary of past events: The party has interacted with the world and taken various actions. Specific details are omitted due to an error."
  end


  # New method to generate a setting description based on a given genre
  def generate_setting(genre)
    system_prompt = <<~PROMPT
      You are a world-building assistant. Given a genre, you will produce a concise but evocative setting description that captures the essence of the genre. The description should be roughly 1-2 sentences. It should provide a vivid environment and atmosphere, and hint at potential conflicts or adventures that await.

      Instructions:
      - Tailor the setting to the given genre.
      - Make it engaging and imaginative.
      - Keep it relatively short (1-2 sentences).
    PROMPT

    user_prompt = "Genre: #{genre}"

    response = @client.chat(
      parameters: {
        model: "gpt-4",
        messages: [
          { role: "system", content: system_prompt },
          { role: "user", content: user_prompt }
        ],
        temperature: 0.7
      }
    )

    setting_description = response.dig("choices", 0, "message", "content")&.strip
    setting_description.presence
  rescue => e
    Rails.logger.error("GPT Setting Generation Error: #{e.message}")
    nil
  end

  private

  # Fallback DM response if no response was generated
  def generate_fallback_dm_response(messages_array, attempted_tool_calls)
    # Construct a detailed prompt for GPT based on the attempted tool calls and full message history.
    fallback_prompt = <<~PROMPT
    You are a Dungeon Master, and a narrative response is missing. GPT attempted to process the following tool calls: 
    #{attempted_tool_calls.any? ? attempted_tool_calls.join(", ") : "No tool calls were made."}

    Based on the full conversation history provided, generate a short and conclusive narrative response that naturally progresses the story. 
    Use the player's most recent actions and the tool calls as a guide to ensure your response aligns with the story's direction.

    This response should:
    - Feel like a continuation of the existing story.
    - Resolve any open-ended player actions or events.
    - Provide closure or guidance for the next steps, even if minimal.
    - Be concise but engaging, avoiding unnecessary repetition.

    # IMPORTANT: 
      - DO NOT TRY TO CALL FUNCTIONS. Your job is to provide a narrative in simple paragraph form and provide ideas for what players could choose to do next. 
  PROMPT

    # Include the full conversation history for context
    conversation_history = messages_array.map { |msg| "#{msg['role'].capitalize}: #{msg['content']}" }.join("\n")

    # Messages for GPT
    messages = [
      { role: "system", content: fallback_prompt },
      { role: "user", content: "Conversation history:\n#{conversation_history}" }
    ]

    begin
      # Generate fallback narrative
      response = @client.chat(
        parameters: {
          model: "gpt-4",
          messages: messages,
          temperature: 0.7
        }
      )
      fallback_text = response.dig("choices", 0, "message", "content")&.strip
      fallback_text.presence
    rescue => e
      Rails.logger.error("Fallback DM Response Error: #{e.message}")
      nil
    end
  end

  def verify_and_fallback_response(message, messages_array)
    dungeon_master_text_response_to_return = "No response generated by GPT."

    # Check if `dungeon_master_text_response` was called
    if message["role"] == "assistant" && message["tool_calls"]
      message["tool_calls"].each do |tool_call|
        if tool_call.dig("function", "name") == "dungeon_master_text_response"
          dungeon_master_text_response_to_return = tool_call.dig("function", "arguments", "content")
          break if dungeon_master_text_response_to_return.present?
        end
      end
    end

    # Generate fallback if no response
    if dungeon_master_text_response_to_return == "No response generated by GPT."
      attempted_tool_calls = message["tool_calls"]&.map { |tc| tc.dig("function", "name") } || []

      Rails.logger.warn("DM response missing. Generating fallback narrative.")
      fallback_narrative = generate_fallback_dm_response(messages_array, attempted_tool_calls)
      dungeon_master_text_response_to_return = fallback_narrative || "The world falls silent, with no further guidance."
    end

    dungeon_master_text_response_to_return
  end


  def define_tools
    [
      {
        type: "function",
        function: {
          name: "update_map_state",
          description: "Update the game map state based on recent changes.",
          parameters: {
            type: :object,
            properties: {
              game_map_state: {
                type: :object,
                properties: {
                  size: {
                    type: :object,
                    properties: {
                      width: { type: :number },
                      height: { type: :number }
                    },
                    required: ["width", "height"]
                  },
                  tiles: {
                    type: :array,
                    items: {
                      type: :object,
                      properties: {
                        x: { type: :number },
                        y: { type: :number },
                        type: { type: :string },
                        description: { type: :string }
                      },
                      required: ["x", "y", "type", "description"]
                    }
                  }
                },
                required: ["size", "tiles"]
              }
            },
            required: ["game_map_state"]
          }
        }
      },
      {
        type: "function",
        function: {
          name: "update_quests",
          description: "Update the quests array to reflect the current quest states.",
          parameters: {
            type: :object,
            properties: {
              quests: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :number },
                    name: { type: :string },
                    description: { type: :string },
                    progress: { type: :string },
                    assigned_to: {
                      type: :array,
                      items: { type: :number }
                    }
                  },
                  required: ["id", "name", "description", "progress", "assigned_to"]
                }
              }
            },
            required: ["quests"]
          }
        }
      },
      {
        type: "function",
        function: {
          name: "update_players",
          description: "Update player data including position, equipment, consumables, meaningful_action, and health.",
          parameters: {
            type: :object,
            properties: {
              players: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :number },
                    position: {
                      type: :object,
                      properties: {
                        x: { type: :number },
                        y: { type: :number }
                      },
                      required: ["x", "y"]
                    },
                    equipment: {
                      type: :array,
                      items: {
                        type: :object,
                        properties: {
                          name: { type: :string },
                          description: { type: :string }
                        },
                        required: ["name", "description"]
                      }
                    },
                    consumables: {
                      type: :object,
                      properties: {
                        teleport: { type: :boolean },
                        health_potion: { type: :boolean },
                        resurrection_token: { type: :boolean }
                      },
                      required: ["teleport", "health_potion", "resurrection_token"]
                    },
                    meaningful_action: { type: :boolean },
                    health: { type: :number }
                  },
                  required: ["id", "position", "equipment", "consumables", "meaningful_action", "health"]
                }
              }
            },
            required: ["players"]
          }
        }
      },
      {
        type: "function",
        function: {
          name: "dungeon_master_text_response",
          description: "Provide the Dungeon Master's narrative text response.",
          parameters: {
            type: :object,
            properties: {
              content: {
                type: :string,
                description: "The narrative text response from the Dungeon Master."
              }
            },
            required: ["content"]
          }
        }
      }
    ]
  end

  # Handle map state updates by modifying the tiles in the database
  def handle_update_map_state(args)
    Rails.logger.debug("handle_update_map_state called with args: #{args.inspect}")

    game_map_state = args[:game_map_state]
    unless game_map_state
      Rails.logger.warn("No game_map_state provided in args.")
      return "No game_map_state provided."
    end

    tiles = game_map_state[:tiles] || []
    Rails.logger.debug("Processing tiles: #{tiles.inspect}")

    # Preload existing tiles to reduce queries
    existing_tiles = @game.tiles.index_by { |t| [t.x_coordinate, t.y_coordinate] }
    Rails.logger.debug("Preloaded existing tiles: #{existing_tiles.keys.inspect}")

    tiles.each do |tile|
      unless tile.is_a?(Hash) && tile.key?(:x) && tile.key?(:y)
        Rails.logger.warn("Skipping invalid tile: #{tile.inspect}")
        next
      end

      key = [tile[:x], tile[:y]]
      db_tile = existing_tiles[key]

      if db_tile
        db_tile.update(
          tile_type: tile[:type],
          image_reference: tile[:description]
        )
        Rails.logger.debug("Updated existing tile at #{key} with type: #{tile[:type]}, description: #{tile[:description]}")
      else
        # Create a new tile if it doesn't exist
        new_tile = @game.tiles.create!(
          x_coordinate: tile[:x],
          y_coordinate: tile[:y],
          tile_type: tile[:type],
          image_reference: tile[:description]
        )
        existing_tiles[key] = new_tile
        Rails.logger.debug("Created new tile at #{key} with type: #{tile[:type]}, description: #{tile[:description]}")
      end
    end

    Rails.logger.info("Map state updated: #{tiles.size} tiles processed.")
    "Map state updated successfully."
  end


  # Handle quests updates (do nothing for now)
  def handle_update_quests(args)
    quests = args[:quests]
    unless quests
      Rails.logger.warn("No quests provided in args.")
      return "No quests provided."
    end

    if quests.is_a?(Array)
      @game.update!(quests: quests.to_json)
      Rails.logger.info("Quests updated successfully.")
      "Quests updated successfully."
    else
      Rails.logger.error("Invalid quests format. Expected an Array, got: #{quests.class}")
      "Invalid quests format. Quests must be an array."
    end
  end

  # Handle player updates: position, equipment, consumables, meaningful_action, health
  def handle_update_players(args)
    Rails.logger.debug("handle_update_players called with args: #{args.inspect}")

    players = args[:players] || []
    Rails.logger.debug("Parsed players: #{players.inspect}")

    return "No players to update." if players.empty?

    # Preload all game_users and their users
    game_users = @game.game_users.includes(:user).index_by(&:user_id)
    Rails.logger.debug("Preloaded game_users: #{game_users.keys.inspect}")

    # Preload tiles by coordinates to minimize queries
    tiles_by_coords = @game.tiles.index_by { |t| [t.x_coordinate, t.y_coordinate] }
    Rails.logger.debug("Preloaded tiles_by_coords: #{tiles_by_coords.keys.inspect}")


    players.each do |player|
      Rails.logger.debug("Processing player: #{player.inspect}")
      if player[:id]
        game_user = game_users[player[:id]]
        unless game_user
          Rails.logger.warn("No game_user found for player ID: #{player[:id]}")
          next
        end

        user = game_user.user
        Rails.logger.debug("Found game_user: #{game_user.inspect}, user: #{user.inspect}")


        # Update position
        if player[:position]
          tile_key = [player[:position][:x], player[:position][:y]]
          Rails.logger.debug("Looking up tile_key: #{tile_key}")
          tile = tiles_by_coords[tile_key]

          if tile
            game_user.update(current_tile_id: tile.id)
            Rails.logger.debug("Updated game_user's current_tile_id to: #{tile.id}")
          else
            Rails.logger.warn("Tile at #{player[:position]} not found. Position not updated.")
          end
        end

        # Update equipment (store as JSON)
        if player[:equipment]
          game_user.update(equipment: player[:equipment].to_json)
          Rails.logger.debug("Updated equipment for game_user #{game_user.id}: #{player[:equipment].to_json}")
        end

        # Update consumables usage
        if player[:consumables]
          consumables = player[:consumables]
          Rails.logger.debug("Player consumables: #{consumables.inspect}")
        end

        # Teleport usage
        if consumables[:teleport]
          if user.teleport > 0
            user.update(teleport: user.teleport - 1)
            Rails.logger.debug("Decremented teleport for user #{user.id}. New value: #{user.teleport - 1}")
          else
            Rails.logger.warn("Tried to use a teleport token but none available for user #{user.id}.")
          end
        end

        # Health potion usage
        if consumables[:health_potion]
          if user.health_potion > 0
            user.update(health_potion: user.health_potion - 1)
            # Restore half health (50 points), capped at 100
            new_health = [game_user.health + 50, 100].min
            game_user.update(health: new_health)
            Rails.logger.debug("Used health_potion for user #{user.id}. New health: #{new_health}")
          else
            Rails.logger.warn("Tried to use a health_potion but none available for user #{user.id}.")
          end
        elsif player[:health]
          # If health potion not used, set health as given by player[:health]
          game_user.update(health: player[:health])
        end

        # Resurrection token usage
        if consumables[:resurrection_token]
          if user.resurrection_token > 0
            user.update(resurrection_token: user.resurrection_token - 1)
            Rails.logger.debug("Decremented resurrection_token for user #{user.id}.")
            # If player's health <= 0, restore to 100
            if game_user.health <= 0
              game_user.update(health: 100)
            end
          else
            Rails.logger.warn("Tried to use resurrection_token but none available for user #{user.id}.")
          end
        end

        # Meaningful action (add 2 shards)
        if player[:meaningful_action]
          Rails.logger.debug("Added 2 shards to user #{user.id}. New shards_balance: #{user.shards_balance + 2}")
          user.update(shards_balance: user.shards_balance + 2)
        end
      end

      Rails.logger.info("Players updated successfully.")
      "Players updated successfully."
    end
  end
end
