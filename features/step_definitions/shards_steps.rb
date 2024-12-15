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
Given(/^the user "([^"]*)" has a shards balance of (\d+)$/) do |email, balance|
  user = User.find_by(email: email)

  # Raise a descriptive error if the user is not found
  raise "User with email #{email} does not exist. Check the test setup." unless user

  # Update the shards balance
  user.update_column(:shards_balance, balance.to_i)
end


When(/^I click the store button$/) do
  find('.store-link').click
end
