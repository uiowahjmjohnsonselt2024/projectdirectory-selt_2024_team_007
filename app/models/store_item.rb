class StoreItem < ActiveRecord::Base
  has_many :user_store_items
  has_many :users, through: :user_store_items
end
