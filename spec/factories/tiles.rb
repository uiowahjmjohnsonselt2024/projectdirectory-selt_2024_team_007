FactoryBot.define do
  factory :tile do
    association :game
    sequence(:x_coordinate) { |n| n }
    sequence(:y_coordinate) { |n| n }
    tile_type { "normal" }
  end
end