class GptDmService
  def initialize(client = OpenAI::Client.new)
    @client = client
  end

  def generate_dm_response(messages_array, game_id, user_id, game_state)
    @game = Game.find(game_id) # Ensure @game is accessible here
    @user_id = user_id
    system_prompt = <<~PROMPT
You are a Dungeon Master for a dynamic and imaginative role-playing game. Your task is to craft an engaging story filled with thrilling encounters, rich lore, and unexpected twists. Players can choose any genre or setting, and your role is to adapt and provide vivid descriptions, balanced challenges, and fair outcomes for player actions.

# IMPORTANT:
    At the end of processing, you MUST call the `dungeon_master_text_response` tool. If you do not call it, the user will have no narrative text to read. Provide a narrative conclusion in that function call every time. Even if there's no story progress, call `dungeon_master_text_response` with some message.

Below is a revised prompt engineering and instructions snippet that ensures GPT understands how to handle the consumable items—**health potion**, **teleport token**, and **resurrection token**—according to the rules. Adjust this snippet in your `generate_dm_response` logic so that GPT consistently applies the intended behavior:

---

**Revised Prompt Snippet:**

**Additional Item Usage Instructions**:  
- The following inventory items: **health potion**, **teleport token**, and **resurrection token** are consumable items. If a player uses one of these items during their turn, set the corresponding flag in the `consumables` object to `true` in the `update_players` function call.
- If the player does not use the corresponding item this turn, set its flag to `false`.
- Always explicitly mention the name of the item(s) used or not used in the `consumables` field.  
- For example:
  - If a player drinks a health potion this turn, when calling `update_players` for that player, make sure `health_potion` is set to `true`. If they do not drink a health potion this turn, set `health_potion` to `false`.
  - If a player uses a teleport token this turn (e.g., to move to a non-adjacent tile), `teleport` should be set to `true`. If they don’t, `teleport` should be set to `false`.
  - If a player uses a resurrection token this turn (e.g., to revive themselves or another), set `resurrection_token` to `true`. If no resurrection action is taken, `resurrection_token` should be `false`.

**Note on Default State**: If a player does not perform any action involving these items, default to `false` for all three.

---

**Example Implementation Detail**:

1. Determine player actions each turn (e.g., did they use a health potion, teleport token, or resurrection token?).  
2. Before calling `update_players`, reflect the used items:
    - `health_potion: true` if used, else `false`
    - `teleport: true` if used, else `false`
    - `resurrection_token: true` if used, else `false`
3. Call `update_players` with the updated `consumables` object along with any other state changes.

**Always** call `dungeon_master_text_response` after all updates to provide the final narrative.

# Instructions

- **Genres & Setting**: Adapt to any genre or setting chosen by the players.
- **Storytelling**: Develop engaging narratives with blind-narrative twists and deep lore.
- **Player Interactions**: Balance challenges and outcomes based on player actions.
- **Inventory Management**: Players may only use items listed in their inventory. 
  - Deny players actions involving unlisted items and provide narrative excuses.
- **Microtransaction Items**: These are non-consumable and cannot be traded. 
  - Use creatively within the story.
- **Player Movement**: Players move on a grid of tiles where each has a description and type.
  - Players can move to **adjacent tiles** freely, as long as no narrative constraint prevents it.
  - To move to **non-adjacent tiles**, players must use a teleport token from their inventory.
  - If a player lacks a teleport token and attempts a non-adjacent move, provide a lore-accurate reason to deny it.
  - If the story mandates that a player stay put (for example, because they are bound by a spell or trapped behind a locked door), you may prevent their movement even to adjacent tiles.
  - If a player uses a teleport token, they can leave their current location regardless of these story constraints (the teleport token overrides the narrative limitation).
- **Map and Player Positions**: The input includes a JSON with the world state, player positions, and inventory lists.
- **Quest Integration**: Incorporate quests as long-term story arcs, subtly influencing the narrative.
- **Rule Enforcement**: Ensure players play according to the rules to maintain fairness.
- **Always** call `dungeon_master_text_response` to provide a final narrative. Failure to do so is an error.
    - The `dungeon_master_text_response` call should be your last tool call once you've decided on the final narrative.
    - If you do not provide a `dungeon_master_text_response`, the user experience will be broken.

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

# Important Distinctions Between Inventory and Equipment

- **Inventory (Microtransaction Items)**: 
  This category contains premium items the player has purchased with real money (e.g., teleport tokens, health potions, resurrection tokens). These items:
  - Cannot be traded or given away.
  - Cannot be spontaneously removed or added by narrative means.
  - Can only be used if specifically allowed (e.g., using a health potion or teleport token).
  - Are non-consumable unless their specific function indicates they are (e.g., health potions are consumable).
  
- **Equipment**:
  This category includes regular items, weapons, tools, and loot found in the world. 
  - Players can pick up or drop these items freely as part of the narrative (e.g., picking up a stick, sword, or shield found on the ground).
  - You, as the Dungeon Master, have the freedom to add or remove items from a player’s equipment to reflect their actions.
  - If a player tries to pick up a mundane object (like a stick) or a non-premium item, you should allow adding it to their equipment if it makes sense in the narrative.
  - If they lose or discard an item, you can remove it from their equipment.
  
# Instructions

- **Player Actions and Equipment**: 
  When a player attempts to pick up a regular, non-premium item from their surroundings (like a stick), you should allow them to add it to their equipment rather than refusing outright. The equipment field represents the player's general assortment of found or earned items, distinct from their premium inventory.

- **Inventory Management Rules**: 
  Inventory items (premium) are restricted and can only be managed according to their defined uses. Do not add random new inventory items to a player’s inventory and do not remove them unless they are consumed as intended.

- **Equipment Management**:
  You have the full authority to add or remove items from equipment based on the player’s narrative actions. For example:
  - If a player picks up a stick, add it to their equipment.
  - If a player discards a weapon, remove it from their equipment.

- **Denying Actions**:
  You should only deny actions that involve adding or removing items from the *inventory* category improperly, or performing actions not allowed by the rules. For normal equipment (non-premium items), embrace and reflect the player’s action by updating their equipment as needed.

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
    else
     # No tool calls, just return the content
     "ERROR! GPT failed to call functions to update game state!"
    end

    # Ensure we retrieve dungeon_master_text_response before falling back
    if dungeon_master_text_response_to_return == "No response generated by GPT."
      Rails.logger.warn("No DM response was directly provided. Checking for a missed response.")

      # Attempt to parse for dungeon_master_text_response if missed in tool_calls
      message["tool_calls"]&.each do |tool_call|
        if tool_call.dig("function", "name") == "dungeon_master_text_response"
          dungeon_master_text_response_to_return = JSON.parse(tool_call.dig("function", "arguments"))[:content]
          break if dungeon_master_text_response_to_return.present?
        end
      end
    end

    # After handling tools, check if we got a DM response
    if dungeon_master_text_response_to_return == "No response generated by GPT."
      Rails.logger.warn("No DM response was provided, attempting fallback DM response.")
      # Attempt a fallback call to GPT to get a narrative text
      fallback_text = generate_fallback_dm_response(messages)
      dungeon_master_text_response_to_return = fallback_text.presence || "The world falls silent, with no further guidance."
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

  # Fallback DM response if no response was generated
  def generate_fallback_dm_response(messages_array)
    # We'll prompt GPT again to produce a simple narrative closing.
    # Since we need a narrative response, we can reference the last user action or just close the scenario gracefully.

    fallback_system_prompt = <<~PROMPT
      You are a Dungeon Master. We attempted to generate a narrative response but did not receive one.
      Provide a short, conclusive narrative message to the user based on the previous conversation.
      This message should feel like the DM responding to the last user action, even if minimal.
      You are NOT calling any tools now; just produce a short narrative as a normal assistant message.
    PROMPT

    # We'll include the last user message or a snippet from messages_array for context.
    last_user_message = messages_array.reverse.find { |m| m["role"] == "user" }&.dig("content") || "No specific user request found."

    messages = [
      { role: "system", content: fallback_system_prompt },
      { role: "user", content: "The last player action/message was: #{last_user_message.inspect}" }
    ]

    begin
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
