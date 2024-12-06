When('I click change profile picture') do
  find('#profilePicture').click
end

And('I attach {string} to {string}') do |file_path, field_name|
  attach_file(field_name, Rails.root.join(file_path))
end

And(/^I attach "([^"]*)" to "([^"]*)":$/) do |file_path, field_name|
  attach_file(field_name, Rails.root.join(file_path))
end
Then('I should see the new profile picture displayed') do
  user = User.last
  expect(page).to have_css("img[src*='#{Rails.application.routes.url_helpers.rails_blob_path(user.profile_image, only_path: true)}']")
end