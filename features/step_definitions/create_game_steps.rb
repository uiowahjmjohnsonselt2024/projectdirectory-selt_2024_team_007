# *********************************************************************
# This file was crafted using assistance from Generative AI Tools.
# Open AI's ChatGPT o1, 4o, and 4o-mini models were used from November 4th 2024 to December 15, 2024.
# The AI Generated code was not sufficient or functional outright nor was it copied at face value.
# Using our knowledge of software engineering, ruby, rails, web development, and the constraints of
# our customer, SELT Team 007 (Cody Alison, Yusuf Halim, Ziad Hasabrabu, Bradley Johnson, and Sheng Wang)
# used GAITs responsibly; verifying that each line made sense in the context of the app,
# conformed to the overall design, and was testable.
# We maintained a strict peer review process before any code changes were merged into the development
# or production branches. All code was tested with BDD and TDD tests as well as empirically tested
# with local run servers and Heroku deployments to ensure compatibility.
# *********************************************************************
Given("the following users exist and want to create a game:") do |users_table|
  users_table.hashes.each do |user_attributes|
    user_attrs = {
      name: user_attributes['name'],
      email: user_attributes['email'],
      password: user_attributes['password'],
      password_confirmation: user_attributes['password']
    }
    FactoryBot.create(:user, user_attrs)
  end
end

Given("a game exists for creation with join code {string}") do |join_code|
  @existing_game = FactoryBot.create(:game, name: "Existing Game", join_code: join_code, owner_user: FactoryBot.create(:user, email: "owner_#{SecureRandom.hex(4)}@example.com"))
end

When("I navigate to the landing page") do
  visit landing_path
end

When("I submit the create game form") do
  # Add WebMock stub for OpenAI API
  # Add WebMock stub for OpenAI API
  stub_request(:post, "https://api.openai.com/v1/chat/completions")
    .with(
      body: hash_including(
        model: "gpt-4",
        messages: lambda { |messages|
          messages.is_a?(Array) &&
            messages.any? { |msg| msg["role"] == "system" && msg["content"].include?("world-building assistant") } &&
            messages.any? { |msg| msg["role"] == "user" && msg["content"].include?("Genre: Fantasy") }
        }
      ),
      headers: {
        'Authorization' => /Bearer .+/,
        'Content-Type' => 'application/json'
      }
    )
    .to_return(
      status: 200,
      body: {
        choices: [
          { message: { content: "A vast and mystical forest filled with ancient ruins and magical creatures." } }
        ]
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )

  within("#createGameModal") do
    click_button "Create Game"
  end
end

Then("the game {string} should be listed in my games") do |game_name|
  within('.scrollable-game-list') do
    expect(page).to have_content(game_name)
  end
end

When('I click on the {string} button') do |string|
  click_button(string)
end

When("I navigate back to the landing page") do
  visit landing_path
end

