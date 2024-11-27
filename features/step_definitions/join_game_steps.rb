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