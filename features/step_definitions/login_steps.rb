Given('the following user exists:') do |table|
  table.hashes.each do |user_data|
    @current_user = User.create!(
      name: "Alice",
      email: "aliyo@email.com",
      password: "passwordiness",
      password_confirmation: "passwordiness"
    )
  end
end

When('I fill in the email field with ') do |email|
  fill_in "email_field", with: email
end

When('I fill in the password field with ') do |password|
  fill_in "password_field", with: password
end

When('I press the sign in button') do |sign_in_button|
  click_button 'sign_in_button'
end

Then('I should be on the user profile page') do
  expect(current_path).to eq(user_path(@current_user))
end

Then(/^I should be on the login page$/) do
  expect(current_path).to eq('/login')
end