class StoreItemsController < ApplicationController


  def index
    @store_items = StoreItem.all
  end

end
