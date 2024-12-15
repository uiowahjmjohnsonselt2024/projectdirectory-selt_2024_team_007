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
# features/step_definitions/create_account_steps.rb


When('I fill in the email field with ') do |email|
  fill_in "email_field", with: email
end

When('I fill in the password field with ') do |password|
  fill_in "password_field", with: password
end

When('I fill in the confirm password field with ') do |password|
  fill_in "password_confirmation_field", with: password
end

When('I press the create account button') do |create_account_button|
  click_button create_account_button
end

Then(/^I should be on the register page$/) do
  expect(current_path).to eq('/register')
end