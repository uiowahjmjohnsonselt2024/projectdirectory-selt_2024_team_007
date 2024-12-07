# app/controllers/store_items_controller.rb


class StoreItemsController < ApplicationController
  before_action :set_currency

  def index
    @store_items = StoreItem.all
    @shard_balance = session[:shard_balance] ||= 100 # Default balance
    @user = current_user
    @shard_packages = [
      { shards: 50, price_usd: 5.00 },
      { shards: 120, price_usd: 10.00 },
      { shards: 250, price_usd: 20.00 }
    ]
  end


  def purchase
    shard_amount = params[:shard_amount].to_i
    item_id = params[:item_id].to_i
    user = current_user # Assuming `current_user` retrieves the logged-in user object

    # Find the item based on the provided ID
    item = StoreItem.find_by(id: item_id)

    if [50, 120, 250].include?(shard_amount)
      # Add shards to user's balance
      user.increment!(:shards_balance, shard_amount)
      flash[:success] = "Purchase successful!"
    elsif shard_amount > 0 && shard_amount <= 5
      if item_id > 3 && user.owns_item?(item_id)
        flash[:warning] = "You already own #{item[:name]}!"
      else
        # Deduct shards and update item count if the user has enough balance
        if user.shards_balance >= shard_amount
          user.decrement!(:shards_balance, shard_amount)
          user.add_store_item(item_id) # Assuming `add_store_item` updates ownership or count
          flash[:success] = "Successfully purchased #{item[:name]}! Remaining shards: #{user.shards_balance}."
        else
          flash[:danger] = "Insufficient Shard Balance. You need #{shard_amount - user.shards_balance} more shards."
        end
      end
    else
      flash[:danger] = "Invalid shard amount! Please select a valid purchase option."
    end

    redirect_to store_items_path
  end

  private

  def set_currency
    user_ip = request.remote_ip
    Rails.logger.debug "****user_ip=#{user_ip}"

    #user_ip = '133.242.187.207' # for test only-japan
    @user_country_code = IpLocationService.get_country_from_ip(user_ip)
    Rails.logger.debug "user_country_code=#{@user_country_code}"

    @currency = country_code_to_currency(@user_country_code)
    @exchange_rate = ExchangeRateService.get_rate(@currency)
  end

  def country_code_to_currency(country_code)
    country = ISO3166::Country[country_code]
    if country && country.currency_code
      country.currency_code
    else
      'USD'
    end
  end


  def current_user
    session_token = session[:session_token]
    User.find_by(session_token: session_token) if session_token.present?
  end
end

