class StoreItem < ActiveRecord::Base

  attr_reader :id, :name, :description, :shards_cost

  STORE_ITEMS = [
    { id: 1, name: 'Teleport', description: 'Instantly teleport to any location.', shards_cost: 0 },
    { id: 2, name: 'Small Health Potion', description: 'Restores 50 HP.', shards_cost: 0 },
    { id: 3, name: 'Invisibility Cloak', description: 'Become invisible for 10 minutes.', shards_cost: 0 },
    { id: 4, name: 'Speed Boost', description: 'Doubles your speed for 5 minutes.', shards_cost: -5 }
  ].freeze

  def self.all
    STORE_ITEMS.map { |item| new(item) }
  end

  def self.find(id)
    item_data = STORE_ITEMS.find { |item| item[:id] == id }
    item_data ? new(item_data) : nil
  end

  def initialize(attributes)
    @id = attributes[:id]
    @name = attributes[:name]
    @description = attributes[:description]
    @shards_cost = attributes[:shards_cost]
  end

  # Custom error for invalid item data
  class InvalidItemError < StandardError; end
end
