require 'openai'

OpenAI.configure do |config|
  config.access_token = ENV.fetch("OPEN_AI_API_KEY_SHARDS_OF_THE_GRID")
  config.log_errors = true # Recommended for development to debug issues
end
