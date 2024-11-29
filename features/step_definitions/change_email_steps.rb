Then('the {string} field should contain {string}') do |field_label, value|
  field = find_field(field_label)
  field_value = (field.tag_name == 'textarea') ? field.text : field.value
  expect(field_value).to eq(value)
end
