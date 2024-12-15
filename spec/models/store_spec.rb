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

RSpec.describe StoreItem, type: :model do
  describe ".all" do
    it "returns all store items from the database" do
      create(:store_item, id: 1, name: "Teleport", shards_cost: 10)
      create(:store_item, id: 2, name: "Invisibility Cloak", shards_cost: 20)

      items = StoreItem.all
      expect(items.size).to eq(2)
      expect(items.first.name).to eq("Teleport")
    end
  end

  describe ".find" do
    before do
      create(:store_item, id: 1, name: "Teleport", shards_cost: 10)
    end

    it "returns the correct item by ID" do
      item = StoreItem.find(1)
      expect(item).to be_a(StoreItem)
      expect(item.name).to eq("Teleport")
    end

    it "returns nil for invalid ID" do
      # Using find_by instead of find to avoid ActiveRecord::RecordNotFound
      item = StoreItem.find_by(id: 999)
      expect(item).to be_nil
    end
  end

  describe "Instance methods" do
    let(:item) { StoreItem.new(id: 1, name: "Teleport", description: "Instantly teleport to any location.", shards_cost: 2) }

    it "has correct attributes" do
      expect(item.name).to eq("Teleport")
      expect(item.description).to eq("Instantly teleport to any location.")
      expect(item.shards_cost).to eq(2)
    end
  end
end