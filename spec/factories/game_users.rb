FactoryBot.define do
  factory :game_user do
    association :user
    association :game
    health { 100 }
  end
end