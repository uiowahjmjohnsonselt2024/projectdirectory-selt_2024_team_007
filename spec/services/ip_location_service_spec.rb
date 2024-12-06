require 'rails_helper'

RSpec.describe IpLocationService, type: :service do
  describe '.get_country_from_ip' do
    let(:ip_address) { '198.168.1.1' }
    let(:url) { "http://ip-api.com/json/#{ip_address}" }

    context 'when the API returns a valid country code' do
      before do
        stub_request(:get, url)
          .to_return(
            status: 200,
            body: { 'countryCode' => 'US' }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns the correct country code' do
        country_code = IpLocationService.get_country_from_ip(ip_address)
        expect(country_code).to eq('US')
      end
    end

    context 'when the API returns an error' do
      before do
        stub_request(:get, url)
          .to_return(
            status: 500,
            body: '',
            headers: {}
          )
      end

      it 'handles the error and returns nil' do
        country_code = IpLocationService.get_country_from_ip(ip_address)
        expect(country_code).to be_nil
      end
    end

    context 'when an exception is raised' do
      before do
        allow(Net::HTTP).to receive(:get).and_raise(StandardError.new('Network error'))
      end

      it 'logs the error and returns nil' do
        expect(Rails.logger).to receive(:error).with(/IP Location Service Error/)
        country_code = IpLocationService.get_country_from_ip(ip_address)
        expect(country_code).to be_nil
      end
    end

    context 'when the API returns invalid JSON' do
      before do
        stub_request(:get, url)
          .to_return(
            status: 200,
            body: 'Invalid JSON',
            headers: {}
          )
      end

      it 'handles the JSON parsing error and returns nil' do
        country_code = IpLocationService.get_country_from_ip(ip_address)
        expect(country_code).to be_nil
      end
    end
  end
end