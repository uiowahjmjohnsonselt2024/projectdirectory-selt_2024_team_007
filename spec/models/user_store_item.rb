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