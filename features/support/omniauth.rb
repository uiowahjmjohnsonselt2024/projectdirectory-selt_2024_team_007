OmniAuth.config.test_mode = true

Given(/^I am logged in as "([^"]*)"$/) do |user|
  case user
  when "Hans"
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: 'google_oauth2',
      uid: '12345',
      info: {
        name: 'Hans Johnson',
        email: 'hans@johnson.com'
      }
    )
  when "Bob"
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: 'google_oauth2',
      uid: '67890',
      info: {
        name: nil,
        email: 'bob@gmail.com'
      }
    )
  else
    raise "Unknown user: #{user}"
  end
  visit '/auth/google_oauth2/callback'
end

