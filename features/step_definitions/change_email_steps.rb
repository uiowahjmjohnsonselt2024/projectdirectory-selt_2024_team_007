When('I click {string} button') do |string|
  click_button(string)
end

Then('I should see the {string} modal') do |modal_title|
  within('.modal') do
    expect(page).to have_content(modal_title)
  end
end

When('I fill in {string} with {string}') do |field_label, value|
  fill_in(field_label, with: value)
end

Then('I should see {string}') do |message|
  expect(page).to have_content(message)
end

Then('the {string} field should contain {string}') do |field_label, value|
  field = find_field(field_label)
  field_value = (field.tag_name == 'textarea') ? field.text : field.value
  expect(field_value).to eq(value)
end
