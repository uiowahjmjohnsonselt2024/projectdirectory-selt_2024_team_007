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

