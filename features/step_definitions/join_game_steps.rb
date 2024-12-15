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
Given("a game exists for joining with join code {string}") do |join_code|
  @game = FactoryBot.create(:game, name: "Mystic Quest", join_code: join_code, owner_user: FactoryBot.create(:user, email: "owner_#{SecureRandom.hex(4)}@example.com"))
end

Given("I have already joined the game with join code {string}") do |join_code|
  @game = Game.find_by(join_code: join_code)
  FactoryBot.create(:game_user, user: @user, game: @game) if @game
end

When("I submit the join game form") do
  within("#joinGameModal") do
    click_button "Join Game"
  end
end

Then('my profile name {string} should be displayed in the game lobby') do |string|
  expect(page).to have_content(string)
end
