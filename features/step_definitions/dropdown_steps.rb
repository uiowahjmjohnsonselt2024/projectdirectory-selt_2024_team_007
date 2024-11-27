When('I click the profile picture') do
  find('#userDropdown').click
end

Then('I should see a dropdown menu with {string}, {string}, and {string}') do |option1, option2, option3|
  expect(page).to have_content(option1)
  expect(page).to have_content(option2)
  expect(page).to have_content(option3)
end
