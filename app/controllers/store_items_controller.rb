class StoreItemsController < ApplicationController

  def index
    @store_items = StoreItem.all
    @shard_balance = session[:shard_balance] ||= 100 # Default balance
  end

  def purchase
    shard_amount = params[:shard_amount].to_i

    user = current_user  # Adjust based on how you get the current user

    if user.shards_balance >= 0
      user.update_column(:shards_balance, user.shards_balance + shard_amount)
      flash[:success] = "Purchase successful!"
      redirect_to store_items_path

    else
      flash[:success] = "Danger!"
      redirect_to store_items_path
    end
  end

  private

  def current_user
    session_token = session[:session_token]
    User.find_by(session_token: session_token) if session_token.present?
  end

end
