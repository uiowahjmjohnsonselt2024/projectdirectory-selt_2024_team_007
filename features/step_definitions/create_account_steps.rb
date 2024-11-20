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
