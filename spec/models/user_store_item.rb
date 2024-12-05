require 'rails_helper.rb'

RSpec.describe UserStoreItem, type: :model do
  let(:user) { User.create(name: "JohnDoe", email: "john@example.com", password: "password", password_confirmation: "password") }
  let(:store_item) { StoreItem.new(id: 1, name: "Teleport", description: "Instantly teleport to any location.", shards_cost: 2) }

  before do
    user.increment_item_count(store_item.id)
  end

  it "associates user with purchased items" do
    user_store_item = UserStoreItem.find_by(user: user, store_item_id: store_item.id)
    expect(user_store_item).to be_present
    expect(user_store_item.user).to eq(user)
    expect(user_store_item.store_item_id).to eq(store_item.id)
  end

  it "tracks quantity of purchased items" do
    user.increment_item_count(store_item.id)
    user_store_item = UserStoreItem.find_by(user: user, store_item_id: store_item.id)
    expect(user_store_item.quantity).to eq(2)
  end
end