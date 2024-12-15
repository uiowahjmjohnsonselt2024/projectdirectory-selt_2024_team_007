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
Given('I have the following friends:') do |table|
  @current_user ||= User.find_by(email: 'alice@example.com') # Adjust email if necessary
  table.hashes.each do |row|
    friend_email = row['email']
    friend = User.find_by(email: friend_email)
    unless friend
      # Create the friend if they don't exist
      friend = User.create!(name: friend_email.split('@').first.capitalize, email: friend_email, password: 'password')
    end
    # Create mutual friendships
    Friendship.create!(user: @current_user, friend: friend, status: 'accepted')
  end
end


Then('I should see {string} in my games') do |game_name|
  within('#my-games') do
    expect(page).to have_content(game_name)
  end
end

When('I click on the {string} button for {string}') do |button_text, game_name|
  game = Game.find_by(name: game_name)
  within("#game-card-#{game.id}") do
    click_button(button_text)
  end
end


When('I select the following friends to invite:') do |table|
  table.hashes.each do |row|
    friend_email = row['email']
    friend = User.find_by(email: friend_email)
    @games = @current_user.games.includes(:game_users).order(created_at: :desc)
    @games.each do |game|
      if game.join_code == "ABC123"
        checkbox_id = "friend_ids_#{game.id}_#{friend.id}"
        check(checkbox_id)
      end
    end
  end
end

When('I submit the invite friends form') do
  click_button 'Invite Friends'
end


Given('{string} is already in the game "{string}"') do |friend_email, game_name|
  friend = User.find_by(email: friend_email)
  game = Game.find_by(name: game_name)
  game.game_users.create!(user: friend, health: 100)
end


When('I check the first {int} friends') do |count|
  within("#addFriendsModal-#{@game.id}") do
    all('input[type="checkbox"]').first(count).each do |checkbox|
      check(checkbox[:id])
    end
  end
end





