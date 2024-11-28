FactoryBot.define do
  factory :store_item do
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.sentence }
    shards_cost { Faker::Number.between(from: 10, to: 50) }
  end
end
