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