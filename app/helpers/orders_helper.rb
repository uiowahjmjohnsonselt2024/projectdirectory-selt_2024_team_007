# app/helpers/orders_helper.rb
module OrdersHelper
  # Define a mapping in a helper method
  def item_icon_path(item_name)
    item_map = {
      "Teleport" => "store_icon_1.png",
      "Small Health Potion" => "store_icon_2.png",
      "Resurrection Token" => "store_icon_3.png",
      "Trickster's Relic" => "store_icon_4.png",
      "Emberscale, Fang of the Crimson Wyrm" => "store_icon_5.png",
      "Bloodwood's Whisper" => "store_icon_6.png",
      "Hearthsteel" => "store_icon_7.png",
      "Clanbreaker" => "store_icon_8.png",
      "Grimoire of the Arcane" => "store_icon_9.png",
      "Emberbane Wand" => "store_icon_10.png",
      "Frostbite Scepter" => "store_icon_11.png",
      "Aegis of the Arcane Sentinel" => "store_icon_12.png",
      "Warbringer's Bulwark" => "store_icon_13.png",
      "Shadowstalker's Vestments" => "store_icon_14.png",
      "Veil of the Arcane Weaver" => "store_icon_15.png",
      "Walter" => "store_icon_16.png",

      # Shard packages
      "10 Shards" => "shards_normal.png",
      "20 Shards" => "shards_medium.png",
      "50 Shards" => "shards_large.png"
    }
    item_map[item_name] || "logo.png" # Fallback to default icon if no match
  end
end
