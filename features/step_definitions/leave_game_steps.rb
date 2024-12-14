Given('a game exists with name {string} and owner {string}') do |game_name, owner_email|
  owner = User.find_by(email: owner_email)
  raise "Owner with email #{owner_email} not found" unless owner

  Game.create!(name: game_name, owner: owner, join_code: 'A1B2C3', map_size: '6x6')
end

Given('{string} has joined the game {string}') do |user_name, game_name|
  user = User.find_by(name: user_name)
  raise "User with name #{user_name} not found" unless user

  game = Game.find_by(name: game_name)
  raise "Game with name #{game_name} not found" unless game

  GameUser.create!(user: user, game: game, health: 100)
end

Then('the game {string} should not be listed in my games') do |game_name|
  expect(page).not_to have_content(game_name)
end

When('I click the Leave Game button inside the {string} game card') do |game_name|
  game = Game.find_by(name: game_name)
  raise "Game with name #{game_name} not found" unless game

  within("#game-card-#{game.id}") do
    click_button 'Leave Game'
  end
end