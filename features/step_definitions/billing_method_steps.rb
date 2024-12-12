

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
