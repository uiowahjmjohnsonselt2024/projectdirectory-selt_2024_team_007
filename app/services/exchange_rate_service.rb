require 'net/http'
require 'json'

# class ExchangeRateService
#   def self.get_rate(target_currency)
#     return 1.0 if target_currency == 'USD'
#
#     url = URI("https://api.exchangerate.host/latest?base=USD&symbols=#{target_currency}")
#     response = Net::HTTP.get(url)
#     data = JSON.parse(response)
#
#     if data['rates'] && data['rates'][target_currency]
#       data['rates'][target_currency].to_f
#     else
#       Rails.logger.error("Exchange Rate API Error: #{data}")
#       1.0
#     end
#   rescue StandardError => e
#     Rails.logger.error("Exchange Rate Service Error: #{e.message}")
#     1.0
#   end
# end
#
class ExchangeRateService
  API_KEY = ENV['EXCHANGE_RATE']

  def self.get_rate(target_currency)
    return 1.0 if target_currency == "USD"

    url = URI("http://data.fixer.io/api/latest?access_key=#{API_KEY}&symbols=#{target_currency},USD")
    response = Net::HTTP.get(url)
    data = JSON.parse(response)

    if data['success']
      rates = data['rates']
      usd_rate = rates['USD']
      target_rate = rates[target_currency]
      target_rate / usd_rate
    else
      Rails.logger.error("Exchange Rate API Error: #{data['error']['info']}")
      1.0
    end
  rescue StandardError => e
    Rails.logger.error("Exchange Rate Service Error: #{e.message}")
    1.0
  end
end