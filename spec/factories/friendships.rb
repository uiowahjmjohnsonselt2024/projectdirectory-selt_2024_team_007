FactoryBot.define do
  factory :friendship do
    user
    friend { association :user }
    status { "pending" }
  end
end