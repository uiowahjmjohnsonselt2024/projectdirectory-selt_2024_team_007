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