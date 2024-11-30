# app/controllers/store_items_controller.rb


class StoreItemsController < ApplicationController
  before_action :set_currency

  def index
    @store_items = StoreItem.all
    @shard_balance = session[:shard_balance] ||= 100 # Default balance
    @shard_packages = [
      { shards: 50, price_usd: 5.00 },
      { shards: 120, price_usd: 10.00 },
      { shards: 250, price_usd: 20.00 }
    ]
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

