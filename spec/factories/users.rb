FactoryBot.define do
  factory :user do
    name { "JohnDoe" }
    email { "john.doe@example.com" }
    password { "password" }
    password_confirmation { "password" }
    session_token { SecureRandom.urlsafe_base64 } # Generate a unique session token
    reset_digest { nil }                         # Typically nil until a reset is initiated
    reset_sent_at { nil }                        # Typically nil until a reset is initiated
    uid { SecureRandom.uuid }                    # Unique identifier for OAuth integrations (if applicable)

    # Trait for a user with an active reset token
    trait :with_reset_token do
      after(:build) do |user|
        user.reset_token = SecureRandom.urlsafe_base64
        user.reset_digest = User.digest(user.reset_token)
        user.reset_sent_at = Time.zone.now
      end
    end
  end
end
