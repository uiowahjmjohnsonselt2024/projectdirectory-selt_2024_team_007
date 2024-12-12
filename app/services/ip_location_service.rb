require 'net/http'
require 'json'

class IpLocationService
  def self.get_country_from_ip(ip)
    url = URI("http://ip-api.com/json/#{ip}")
    response = Net::HTTP.get(url)
    data = JSON.parse(response)
    data['countryCode']
  rescue StandardError => e
    Rails.logger.error("IP Location Service Error: #{e.message}")
    nil
  end
end

# cache
# class IpLocationService
#   def self.get_country_from_ip(ip)
#     Rails.cache.fetch("country_for_ip_#{ip}", expires_in: 1.hour) do
#       url = URI("http://ip-api.com/json/#{ip}")
#       response = Net::HTTP.get(url)
#       data = JSON.parse(response)
#       data['country']
#     rescue StandardError => e
#       Rails.logger.error("IP Location Service Error: #{e.message}")
#       nil
#     end
#   end
# end