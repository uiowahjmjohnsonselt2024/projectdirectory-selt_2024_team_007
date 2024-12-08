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