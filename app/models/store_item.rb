class StoreItem < ActiveRecord::Base

  def self.all_items
    StoreItem.all
  end

  # Find a StoreItem by name (case-insensitive search)
  def self.find_by_name(name)
    StoreItem.where('lower(name) = ?', name.downcase).first
  end

  # Create a new StoreItem with specified attributes
  def self.create_item(name, price, description)
    StoreItem.create!(
      name: name,
      price: price,
      description: description || "No description available."
    )
  end

  # Custom error for invalid item data
  class InvalidItemError < StandardError; end
end
