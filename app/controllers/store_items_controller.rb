class StoreItemsController < ApplicationController

  before_action :authenticate_user!

  def index
    @store_items = StoreItem.all
  end

  def authenticate_user!
    unless session[:user_id]
      flash[:alert] = "You must be logged in to access this page."
      redirect_to login_path
    end
  end

end
