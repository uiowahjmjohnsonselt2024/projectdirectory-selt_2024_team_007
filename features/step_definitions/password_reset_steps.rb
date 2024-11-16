Given(/^the following users exist:$/) do |users_table|
  users_table.hashes.each do |user_attrs|
    User.create!(
      name: user_attrs['name'],
      email: user_attrs['email'],
      password: user_attrs['password'],
      password_confirmation: user_attrs['password']
    )
  end
end

Given(/^the following users have requested password reset:$/) do |users_table|
  users_table.hashes.each do |user_attrs|
    user = User.find_by(email: user_attrs['email'])
    user.create_reset_digest
    @user = user # Store for later use
  end
end

Given(/^a valid password reset link exists for "(.*)"$/) do |email|
  user = User.find_by(email: email)
  user.create_reset_digest unless user.reset_token
  @user = user
end

When(/^I visit the reset link with valid token$/) do
  visit edit_password_reset_path(@user.reset_token, email: @user.email)
end

When(/^I fill in the password field with "(.*)"$/) do |password|
  fill_in 'new_password_field', with: password
end

When(/^I fill in the password confirmation field with "(.*)"$/) do |password_confirmation|
  fill_in 'password_confirmation_field', with: password_confirmation
end

When(/^I click the "(.*)" button$/) do |button_name|
  click_button(button_name)
end

When(/^I visit the reset link with token "(.*)"$/) do |token|
  visit edit_password_reset_path(token, email: 'user@example.com')
end

Then(/^I should be on "(.*)"$/) do |expected_path|
  expect(current_path).to eq(expected_path)
end

Then(/^I should not be on "(.*)"$/) do |expected_path|
  expect(current_path).to_not eq(expected_path)
end

Then(/^I should be on the password reset page$/) do
  expect(current_path).to eq(edit_password_reset_path(@user.reset_token))
end

Then(/^I am at my profile page$/) do
  user = User.find_by(email: @user.email) # Replace with the appropriate email or method
  expect(current_path).to eq(user_path(user))
end