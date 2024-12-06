# spec/factories/games.rb
FactoryBot.define do
  factory :game do
    sequence(:name) { |n| "Game #{n}" }
    sequence(:join_code) { |n| "G#{n.to_s.rjust(5, '0')}" } # Generates "G00001", "G00002", etc.
    map_size { "6x6" }

    transient do
      owner_user { nil }
    end

    after(:build) do |game, evaluator|
      # Assign the specified owner_user or create a new one
      game.owner = evaluator.owner_user || create(:user)
      # Set current_turn_user to owner to prevent creating a second user
      game.current_turn_user = game.owner
    end
  end
end