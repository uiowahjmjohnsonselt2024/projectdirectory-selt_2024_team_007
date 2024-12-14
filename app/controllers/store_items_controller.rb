# app/controllers/store_items_controller.rb


class StoreItemsController < ApplicationController
  before_action :set_currency

  def index
    @store_items = StoreItem.all
    @shard_balance = session[:shard_balance] ||= 100 # Default balance
    @user = current_user
    @shard_packages = [
      { shards: 10, price_usd: 7.50 },
      { shards: 20, price_usd: 15.00 },
      { shards: 50, price_usd: 37.50 }
    ]
  end


  def purchase
    shard_amount = params[:shard_amount].to_i
    item_id = params[:item_id].to_i
    user = current_user
    item = StoreItem.find_by(id: item_id)

    # Handle shard packages
    if [10, 20, 50].include?(shard_amount)
      if BillingMethod.exists?(user_id: current_user.id)
        user.increment!(:shards_balance, shard_amount)
        flash[:success] = "Purchase successful!"
        redirect_to store_items_path and return
      elsif
        flash[:danger] = "Please add a Payment Method"
        redirect_to store_items_path and return
      end
    end

    # Handle store items based on item_id and item existence
    if item.present?
      # Use the item's cost, not the passed shard_amount parameter
      actual_cost = item.shards_cost

      # Check if user already owns the item
      if item_id > 3 && user.owns_item?(item_id)
        flash[:warning] = "You already own #{item[:name]}!"
      else
        # Check for sufficient balance
        if user.shards_balance >= actual_cost
          user.decrement!(:shards_balance, actual_cost)
          user.add_store_item(item_id)
          flash[:success] = "Successfully purchased #{item[:name]}! Remaining shards: #{user.shards_balance}."
        else
          needed = actual_cost - user.shards_balance
          flash[:danger] = "Insufficient Shard Balance. You need #{needed} more shards."
        end
      end
    else
      # If it's not a shard package and there's no valid item, mark invalid
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

