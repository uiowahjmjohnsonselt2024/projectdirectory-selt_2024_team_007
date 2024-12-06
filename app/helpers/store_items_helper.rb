module StoreItemsHelper
  def display_price(price_in_usd)
    converted_price = (price_in_usd * @exchange_rate).round(2)
    formatted_price = format('%.2f', converted_price)
    "#{@currency} #{formatted_price}"
  end
end