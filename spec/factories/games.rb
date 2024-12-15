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