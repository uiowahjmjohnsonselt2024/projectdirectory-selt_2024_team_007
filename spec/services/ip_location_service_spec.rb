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