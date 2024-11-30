module StoreItemsHelper
  def display_price(price_in_usd)
    converted_price = (price_in_usd * @exchange_rate).round(2)
    "#{@currency} #{converted_price}"
  end
end