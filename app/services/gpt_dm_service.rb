class GptDmService
  def initialize(client = OpenAI::Client.new)
    @client = client
  end

  def generate_dm_response(user_message)
    system_prompt = <<~PROMPT
      You are a Dungeon Master for a dynamic and imaginative game of Dungeons & Dragons. 
      Your task is to craft an engaging story filled with thrilling encounters, rich lore, 
      and unexpected twists. Players can choose any genre or setting, and your role is to 
      adapt and provide vivid descriptions, balanced challenges, and fair outcomes for player actions.
    PROMPT

    messages = [
      { role: "system", content: system_prompt },
      { role: "user", content: user_message }
    ]

    response = @client.chat(
      parameters: {
        model: "gpt-4o", # Replace with the specific model you want to use
        messages: messages,
        temperature: 0.7
      }
    )

    response.dig("choices", 0, "message", "content")
    rescue => e
      Rails.logger.error("GPT API Error: #{e.message}")
      "An error occurred while generating the response."
  end
end
