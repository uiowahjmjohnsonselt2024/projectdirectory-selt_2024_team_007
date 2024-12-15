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

When('I click Billings button') do
  find('#v-pills-billings-tab').click
end

When('I fill in the following fields for the billing method:') do |table|
  within('#addCardModal') do
    table.rows_hash.each do |field, value|
      fill_in(field, with: value)
    end
  end
end

When('I edit the following fields for the card ending in {string}:') do |last_4_digits, table|
  within("#editCardModal-#{last_4_digits}") do
    table.rows_hash.each do |field, value|
      fill_in(field, with: value)
    end
  end
end

Given('the following billing methods exist:') do |table|
  table.hashes.each do |billing_method|
    BillingMethod.create!(
      card_number: billing_method['Card Number'],
      card_holder_name: billing_method['Card Holder Name'],
      expiration_date: Date.strptime(billing_method['Expiration Date'], '%m/%y'),
      cvv: billing_method['CVV'],
      user: @current_user # Ensure the billing method is tied to the correct user
    )
  end
end

When('I click the "Edit" button for the card ending with {string}') do |last_four_digits|
  find("button[data-card-last-four='#{last_four_digits}']", visible: :all).click
end
