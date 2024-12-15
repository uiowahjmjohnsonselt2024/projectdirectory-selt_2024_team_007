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
Given('there are store items available') do
  StoreItem.create(name: 'Item 1', price_usd: 5.00)
  StoreItem.create(name: 'Item 2', price_usd: 10.00)
end

Given('I have a shard balance of {int}') do |balance|
  page.set_rack_session(shard_balance: balance)
end

When('I visit the store items page') do
  visit store_items_path
end

Then('I should see a list of store items') do
  expect(page).to have_content('Item 1')
  expect(page).to have_content('Item 2')
end

Then('I should see my current shard balance') do
  balance = page.evaluate_script("document.querySelector('#shard-balance').textContent").to_i
  expect(balance).to eq 100
end

When('I purchase {int} shards') do |amount|
  click_button "Purchase #{amount} Shards"
end

Then('my shard balance should be {int}') do |expected_balance|
  balance = page.evaluate_script("document.querySelector('#shard-balance').textContent").to_i
  expect(balance).to eq expected_balance
end

Then('my shard balance should remain {int}') do |expected_balance|
  balance = page.evaluate_script("document.querySelector('#shard-balance').textContent").to_i
  expect(balance).to eq expected_balance
end

Then('I should see a success message') do
  expect(page).to have_content('Purchase successful!')
end

Then('I should see an error message') do
  expect(page).to have_content('Insufficient balance')
end

Then('I should see prices in {string}') do |expected_currency|
  expect(page).to have_content("#{expected_currency}")
end

Given('I am a user from {string}') do |nothing|
  # This sentence is just for customer to read
  # The country already written on the top of scenario
end
