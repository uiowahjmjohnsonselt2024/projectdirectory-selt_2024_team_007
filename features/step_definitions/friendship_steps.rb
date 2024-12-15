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
