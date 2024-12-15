class UserStoreItem < ApplicationRecord
  belongs_to :user
  belongs_to :store_item
end
