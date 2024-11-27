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
