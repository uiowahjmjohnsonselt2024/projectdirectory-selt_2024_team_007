# *********************************************************************
# This file was crafted using assistance from Generative AI Tools. 
# Open AI's ChatGPT o1, 4o, and 4o-mini models were used from November 
# 4th 2024 to December 15, 2024. The AI Generated code was not 
# sufficient or functional outright nor was it copied at face value. 
# Using our knowledge of software engineering, ruby, rails, web 
# development, and the constraints of our customer, SELT Team 007 
# (Cody Alison, Yusuf Halim, Ziad Hasabrabu, Bradley Johnson, 
# and Sheng Wang) used GAITs responsibly; verifying that each line made
# sense in the context of the app, conformed to the overall design, 
# and was testable. We maintained a strict peer review process before
# any code changes were merged into the development or production 
# branches. All code was tested with BDD and TDD tests as well as 
# empirically tested with local run servers and Heroku deployments to
# ensure compatibility.
# *******************************************************************
FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "JohnDoe#{n}" }
    sequence(:email) { |n| "john.doe#{n}@example.com" }
    password { "password" }
    password_confirmation { "password" }
    session_token { SecureRandom.urlsafe_base64 }
    reset_digest { nil }
    reset_sent_at { nil }
    uid { SecureRandom.uuid }

    # Keep existing trait
    trait :with_reset_token do
      after(:build) do |user|
        user.reset_token = SecureRandom.urlsafe_base64
        user.reset_digest = User.digest(user.reset_token)
        user.reset_sent_at = Time.zone.now
      end
    end
  end
end