# app/helpers/orders_helper.rb
module OrdersHelper
  # Define a mapping in a helper method
  def item_icon_path(item_name)
    item_map = {
      "Teleport" => "store_icon_1.png",
      "Small Health Potion" => "store_icon_2.png",
      "Resurrection Token" => "store_icon_3.png",
      # Add other store items here
    }
    item_map[item_name] || "default_icon.png" # Fallback to default icon if no match
  end
end
