Given(/^Jane Smith has sent me a friend request$/) do
  jane = User.find_by(email: "jane@example.com")
  user = User.find_by(email: "john@example.com") # Replace "john@example.com" with your logged-in user

  # Ensure the current user is set
  @current_user = user

  # Create a pending friend request
  jane.friendships.create!(friend: user, status: "pending")
end

Given(/^I have sent a friend request to "([^"]*)"$/) do |friend_name|
  friend = User.find_by(name: friend_name)
  @current_user.pending_friendships.create!(friend: friend, status: "pending")
end

Then(/^"([^"]*)" should be in "([^"]*)"$/) do |friend_name, section|
  within(".scrollable-friends-list") do
    expect(page).to have_content(friend_name)
  end
end

Then(/^"([^"]*)" should not be in "([^"]*)"$/) do |friend_name, section|
  within(".scrollable-friends-list") do
    expect(page).not_to have_content(friend_name)
  end
end
