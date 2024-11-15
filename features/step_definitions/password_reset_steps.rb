Given("the following user exists:") do |table|
  table.hashes.each do |user|
    User.create!(
      name: user["name"],
      email: user["email"],
      password: user["password"],
      password_confirmation: user["password"]
    )
  end
end

Given("a valid password reset link exists for {string}") do |email|
  @user = User.find_by(email: email)
  @user.create_reset_digest
  # Simulate sending the reset link
  @reset_link = edit_password_reset_path(@user.reset_token, email: @user.email)
end

When("I visit the reset link") do
  visit @reset_link
end

When("I enter {string} in the password field") do |password|
  fill_in "Password", with: password
end

When("I enter {string} in the password confirmation field") do |password_confirmation|
  fill_in "Password confirmation", with: password_confirmation
end

When("I click {string}") do |button_text|
  click_button button_text
end

Then("I should see {string}") do |message|
  expect(page).to have_content(message)
end

Then("I should be logged in") do
  expect(page).to have_content("Welcome, #{@user.name}")
end
