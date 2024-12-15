# *********************************************************************
# This file was crafted using assistance from Generative AI Tools.
# Open AI's ChatGPT o1, 4o, and 4o-mini models were used from November
# 4th 2024 to December 15, 2024. The AI Generated code was not
# sufficient or functional outright nor was it copied at face value.
# Using our knowledge of software engineering, ruby, rails, web
# development, and the constraints of our customer, SELT Team 007
# (Cody Alison, Yusuf Halim, Ziad Hasabrabu, Bradley Johnson,
# and Sheng Wang) used GAITs responsibly; verifying that each line made
# sense in the context of the app, conformed to the overall design,
# and was testable. We maintained a strict peer review process before
# any code changes were merged into the development or production
# branches. All code was tested with BDD and TDD tests as well as
# empirically tested with local run servers and Heroku deployments to
# ensure compatibility.
# *******************************************************************
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
        Order.create!(
          user: user,
          item_name: "#{shard_amount} Shards",
          item_type: "Shard Package",
          item_cost: shard_amount,
          purchased_at: Time.zone.now
        )
        flash[:success] = "Purchase successful!"
        redirect_to store_items_path and return
      else
        flash[:danger] = "Please add a Payment Method"
        redirect_to store_items_path and return
      end
    end

    # Handle store items based on item_id and item existence
    if item.present?
      actual_cost = item.shards_cost

      if item_id > 3 && user.owns_item?(item_id)
        flash[:warning] = "You already own #{item[:name]}!"
      else
        if user.shards_balance >= actual_cost
          user.decrement!(:shards_balance, actual_cost)
          user.add_store_item(item_id)
          Order.create!(
            user: user,
            item_name: item.name,
            item_type: "Store Item",
            item_cost: actual_cost,
            purchased_at: Time.zone.now
          )
          flash[:success] = "Successfully purchased #{item[:name]}!"
        else
          needed = actual_cost - user.shards_balance
          flash[:danger] = "Insufficient Shard Balance. You need #{needed} more shards."
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

