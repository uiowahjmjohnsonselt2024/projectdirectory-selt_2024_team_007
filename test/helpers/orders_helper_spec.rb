require 'rails_helper'

RSpec.describe OrdersHelper, type: :helper do
  describe "#item_icon_path" do
    # Tests for Shard Packages
    it "returns the correct icon for shard packages" do
      expect(helper.item_icon_path("10 Shards")).to eq("shards_normal.png")
      expect(helper.item_icon_path("20 Shards")).to eq("shards_medium.png")
      expect(helper.item_icon_path("50 Shards")).to eq("shards_large.png")
    end

    # Tests for Store Items
    it "returns the correct icon for store items" do
      expect(helper.item_icon_path("Teleport")).to eq("store_icon_1.png")
      expect(helper.item_icon_path("Small Health Potion")).to eq("store_icon_2.png")
      expect(helper.item_icon_path("Resurrection Token")).to eq("store_icon_3.png")
      expect(helper.item_icon_path("Trickster's Relic")).to eq("store_icon_4.png")
      expect(helper.item_icon_path("Emberscale, Fang of the Crimson Wyrm")).to eq("store_icon_5.png")
      expect(helper.item_icon_path("Bloodwood's Whisper")).to eq("store_icon_6.png")
      expect(helper.item_icon_path("Hearthsteel")).to eq("store_icon_7.png")
      expect(helper.item_icon_path("Clanbreaker")).to eq("store_icon_8.png")
      expect(helper.item_icon_path("Grimoire of the Arcane")).to eq("store_icon_9.png")
      expect(helper.item_icon_path("Emberbane Wand")).to eq("store_icon_10.png")
      expect(helper.item_icon_path("Frostbite Scepter")).to eq("store_icon_11.png")
      expect(helper.item_icon_path("Aegis of the Arcane Sentinel")).to eq("store_icon_12.png")
      expect(helper.item_icon_path("Warbringer's Bulwark")).to eq("store_icon_13.png")
      expect(helper.item_icon_path("Shadowstalker's Vestments")).to eq("store_icon_14.png")
      expect(helper.item_icon_path("Veil of the Arcane Weaver")).to eq("store_icon_15.png")
      expect(helper.item_icon_path("Walter")).to eq("store_icon_16.png")
    end

    # Test for an unknown item
    it "returns the default icon for unknown items" do
      expect(helper.item_icon_path("Unknown Item")).to eq("logo.png")
    end
  end
end
