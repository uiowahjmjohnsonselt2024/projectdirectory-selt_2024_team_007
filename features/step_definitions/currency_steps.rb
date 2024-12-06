Given('there are store items available') do
  # 创建一些模拟的 StoreItem
  StoreItem.create(name: 'Item 1', price_usd: 5.00)
  StoreItem.create(name: 'Item 2', price_usd: 10.00)
end

Given('I have a shard balance of {int}') do |balance|
  # 设置会话或用户的初始余额
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
