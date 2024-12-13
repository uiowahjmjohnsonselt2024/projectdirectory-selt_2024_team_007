class GptDmService
  def initialize(client = OpenAI::Client.new)
    @client = client
  end

  def generate_dm_response(messages_array)
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
    tools = [
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
          # Here you would handle updating the map state in your database or memory
          "Map state updated successfully."
        when "update_quests"
          # Update quests in your database or memory
          "Quests updated successfully."
        when "update_players"
          # Update players data
          "Players updated successfully."
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
end
