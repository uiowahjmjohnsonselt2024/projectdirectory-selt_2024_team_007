class GptDmService
  def initialize(client = OpenAI::Client.new)
    @client = client
  end

  def generate_dm_response(messages_array, game_id, user_id, game_state)
    @game = Game.find(game_id) # Ensure @game is accessible here
    @user_id = user_id
    system_prompt = <<~PROMPT
You are a Dungeon Master for a dynamic and imaginative game of Dungeons & Dragons. Your task is to craft an engaging story filled with thrilling encounters, rich lore, and unexpected twists. Players can choose any genre or setting, and your role is to adapt and provide vivid descriptions, balanced challenges, and fair outcomes for player actions.

# Instructions

- **Genres & Setting**: Adapt to any genre or setting chosen by the players.
- **Storytelling**: Develop engaging narratives with blind-narrative twists and deep lore.
- **Player Interactions**: Balance challenges and outcomes based on player actions.
- **Inventory Management**: Players may only use items listed in their inventory. 
  - Deny players actions involving unlisted items and provide narrative excuses.
- **Microtransaction Items**: These are non-consumable and cannot be traded. 
  - Use creatively within the story.
- **Player Movement**: Players move on a grid of tiles where each has a description and type.
  - Players move only to adjacent tiles unless the story requires them to stay.
- **Map and Player Positions**: The input includes a JSON with the world state, player positions, and inventory lists.
- **Quest Integration**: Incorporate quests as long-term story arcs, subtly influencing the narrative.
- **Rule Enforcement**: Ensure players play according to the rules to maintain fairness.

# Additional Instructions for Quests
- **Quest Summarization**: If the total quest data is too large to process within the token limit, summarize the quests. Focus on the essential details:
  - Summarize active quests with a short description, current progress, and key assigned players.
  - Retain critical elements of the quests necessary for the current gameplay.
- Always prioritize preserving quest details relevant to the current player actions and context.

# Steps

1. **Analyze Input JSON**: Review the provided game state, including player positions, inventory, map state, and quests.
2. **Creative Storytelling**: Craft a dynamic response to player actions while adhering to the game's rules.
3. **Enforce Game Rules**:
   - Players with health at 0 or below cannot act unless they or another player uses a resurrection token to revive them. 
   - Players cannot move to non-adjacent tiles unless they use a teleport token. If they lack a teleport token, provide a lore-accurate reason for denying the move.
   - Health potions restore half of the player’s maximum health (assume 100 health points max unless stated otherwise).
4 **Inventory Management**: Update a player's equipment when players acquire new equipment items or lose one they had.
5. **Update State**: Modify the game state based on player actions (e.g., using consumables, changing positions, or completing quests).


# Output Format
      You will use the provided functions (tools) to update the game state instead of returning a JSON directly.
      When you have decided on the final changes to the map state, quests, and players, call the corresponding functions:

      - Call `update_map_state` with the updated game_map_state.
      - Call `update_quests` with the updated quests array.
      - Call `update_players` with the updated players array.
      - Call `dungeon_master_text_response` with the DM's narrative text.

      After calling these functions and receiving their results, conclude with a final narrative message to the user if needed.

# Notes

- Deny usage of any unlisted items with an in-story rationale.
- Ensure the seamless integration of quest elements without revealing them overtly.
- Comply with the system's authoritative updates on player locations.
- Prioritize a fun and engaging experience while adhering to game rules.
- Deny unreasonable player actions with an in-story rationale.

    PROMPT

    ## KEEPING FOR LATER IN CASE THE JSON SCHEMA BECOMES SUPPORTED BY THE LIBRARY WE ARE USING FOR OPEN AI API CALLS
    json_schema = <<~SCHEMA
{
  "name": "my_schema",
  "schema": {
    "type": "object",
    "properties": {
      "name": {
        "type": "string",
        "description": "The name of the schema"
      },
      "type": {
        "type": "string",
        "enum": [
          "object"
        ]
      },
      "properties": {
        "type": "object",
        "properties": {
          "dungeon_master_text_response": {
            "type": "object",
            "properties": {
              "content": {
                "type": "string",
                "description": "The narrative text response from the Dungeon Master."
              }
            },
            "required": [
              "content"
            ],
            "additionalProperties": false
          },
          "game_map_state": {
            "type": "object",
            "properties": {
              "size": {
                "type": "object",
                "properties": {
                  "width": {
                    "type": "number"
                  },
                  "height": {
                    "type": "number"
                  }
                },
                "required": [
                  "width",
                  "height"
                ],
                "additionalProperties": false
              },
              "tiles": {
                "type": "array",
                "items": {
                  "type": "object",
                  "properties": {
                    "x": {
                      "type": "number"
                    },
                    "y": {
                      "type": "number"
                    },
                    "type": {
                      "type": "string",
                      "description": "The type of tile on the game map."
                    },
                    "description": {
                      "type": "string",
                      "description": "Description of the tile."
                    }
                  },
                  "required": [
                    "x",
                    "y",
                    "type",
                    "description"
                  ],
                  "additionalProperties": false
                }
              }
            },
            "required": [
              "size",
              "tiles"
            ],
            "additionalProperties": false
          },
          "quests": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "id": {
                  "type": "number"
                },
                "name": {
                  "type": "string"
                },
                "description": {
                  "type": "string"
                },
                "progress": {
                  "type": "string"
                },
                "assigned_to": {
                  "type": "array",
                  "items": {
                    "type": "number"
                  }
                }
              },
              "required": [
                "id",
                "name",
                "description",
                "progress",
                "assigned_to"
              ],
              "additionalProperties": false
            }
          },
          "players": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "id": {
                  "type": "number"
                },
                "position": {
                  "type": "object",
                  "properties": {
                    "x": {
                      "type": "number"
                    },
                    "y": {
                      "type": "number"
                    }
                  },
                  "required": [
                    "x",
                    "y"
                  ],
                  "additionalProperties": false
                },
                "equipment": {
                  "type": "array",
                  "items": {
                    "type": "object",
                    "properties": {
                      "name": {
                        "type": "string"
                      },
                      "description": {
                        "type": "string"
                      }
                    },
                    "required": [
                      "name",
                      "description"
                    ],
                    "additionalProperties": false
                  }
                },
                "consumables": {
                  "type": "object",
                  "properties": {
                    "teleport": {
                      "type": "boolean"
                    },
                    "health_potion": {
                      "type": "boolean"
                    },
                    "resurrection_token": {
                      "type": "boolean"
                    }
                  },
                  "required": [
                    "teleport",
                    "health_potion",
                    "resurrection_token"
                  ],
                  "additionalProperties": false
                },
                "meaningful_action": {
                  "type": "boolean"
                },
                "health": {
                  "type": "number"
                }
              },
              "required": [
                "id",
                "position",
                "equipment",
                "consumables",
                "meaningful_action",
                "health"
              ],
              "additionalProperties": false
            }
          }
        },
        "required": [
          "dungeon_master_text_response",
          "game_map_state",
          "quests",
          "players"
        ],
        "additionalProperties": false
      }
    },
    "required": [
      "name",
      "type",
      "properties"
    ],
    "additionalProperties": false,
    "$defs": {}
  },
  "strict": true
}
    SCHEMA


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

    # Append the tool call and result back into the conversation
    # Commented out for now because I don't think we actually need GPT to do a second pass
    # based on the tool response. If we ever needed to add that, this is how you would do
    # it.
    # messages << message
    # messages << {
    #   tool_call_id: tool_call_id,
    #   role: "tool",
    #   name: function_name,
    #   content: function_response
    # }
    else
     # No tool calls, just return the content
     "ERROR! GPT failed to call functions to update game state!"
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

  private

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

  #TODO Ziad all the stuff below should work but we dont have access to @game or @game_users or @users

  # Handle map state updates by modifying the tiles in the database
  def handle_update_map_state(args)
    game_map_state = args[:game_map_state]
    return unless game_map_state

    tiles = game_map_state[:tiles] || []
    # Preload existing tiles to reduce queries
    existing_tiles = @game.tiles.index_by { |t| [t.x_coordinate, t.y_coordinate] }

    tiles.each do |tile|
      key = [tile[:x], tile[:y]]
      db_tile = existing_tiles[key]

      if db_tile
        db_tile.update(tile_type: tile[:type], image_reference: tile[:description])
      else
        # Create a new tile if it doesn't exist
        new_tile = @game.tiles.create!(
          x_coordinate: tile[:x],
          y_coordinate: tile[:y],
          tile_type: tile[:type],
          image_reference: tile[:description]
        )
        existing_tiles[key] = new_tile
      end
    end

    Rails.logger.info("Map state updated: #{tiles.size} tiles processed.")
    "Map state updated successfully."
  end

  # Handle quests updates (do nothing for now)
  def handle_update_quests(args)
    quests = args[:quests]
    return "No quests provided." unless quests

    @game.update!(quests: quests.to_json)
    Rails.logger.info("Quests updated successfully.")
    "Quests updated successfully."
  end

  # Handle player updates: position, equipment, consumables, meaningful_action, health
  def handle_update_players(args)
    players = args[:players] || []
    return "No players to update." if players.empty?

    # Preload all game_users and their users
    game_users = @game.game_users.includes(:user).index_by(&:user_id)

    # Preload tiles by coordinates to minimize queries
    tiles_by_coords = @game.tiles.index_by { |t| [t.x_coordinate, t.y_coordinate] }

    players.each do |player|
      game_user = game_users[player[:id]]
      next unless game_user # Skip if no such player in this game

      user = game_user.user

      # Update position
      tile_key = [player[:position][:x], player[:position][:y]]
      tile = tiles_by_coords[tile_key]

      if tile
        game_user.update(current_tile_id: tile.id)
      else
        Rails.logger.warn("Tile at #{player[:position]} not found. Position not updated.")
      end

      # Update equipment (store as JSON)
      game_user.update(equipment: player[:equipment].to_json)

      # Update consumables usage
      consumables = player[:consumables]

      # Teleport usage
      if consumables[:teleport]
        if user.teleport > 0
          user.update(teleport: user.teleport - 1)
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
        else
          Rails.logger.warn("Tried to use a health_potion but none available for user #{user.id}.")
        end
      else
        # If health potion not used, set health as given by player[:health]
        game_user.update(health: player[:health])
      end

      # Resurrection token usage
      if consumables[:resurrection_token]
        if user.resurrection_token > 0
          user.update(resurrection_token: user.resurrection_token - 1)
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
        user.update(shards_balance: user.shards_balance + 2)
      end
    end

    Rails.logger.info("Players updated successfully.")
    "Players updated successfully."
  end
end
