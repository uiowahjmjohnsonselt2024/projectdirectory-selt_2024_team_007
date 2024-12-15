When('I click {string} in the dropdown menu') do |link_text|
  puts page.body
  find('img[alt="Profile Picture"]').click
  click_link link_text
end

Then('I should be redirected to the settings page') do
  expect(current_path).to eq(settings_path)
end
Then('I should be redirected to the User Guide page') do
  expect(current_path).to eq(user_guide_path)
end
Then('I should be redirected to the friends page') do
  expect(current_path).to eq(friends_path)
end
