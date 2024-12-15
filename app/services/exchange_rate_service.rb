# *********************************************************************
# This file was crafted using assistance from Generative AI Tools.
#   Open AI's ChatGPT o1, 4o, and 4o-mini models were used from November
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
require 'net/http'
require 'json'

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