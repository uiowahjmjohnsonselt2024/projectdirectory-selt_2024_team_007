require 'rails_helper'

RSpec.describe ExchangeRateService, type: :service do
  describe '.get_rate' do
    before do
      allow(ENV).to receive(:[]).with('EXCHANGE_RATE').and_return(ENV['EXCHANGE_RATE'])
    end
    let(:target_currency) { 'EUR' }
    let(:url) { "http://data.fixer.io/api/latest?access_key=#{ENV['EXCHANGE_RATE']}&symbols=#{target_currency},USD" }

    context 'when target_currency is USD' do
      it 'returns 1.0 without making an HTTP request' do
        expect(Net::HTTP).not_to receive(:get)
        rate = ExchangeRateService.get_rate('USD')
        expect(rate).to eq(1.0)
      end
    end

    context 'when API returns a successful response' do
      before do
        stub_request(:get, url)
          .to_return(
            status: 200,
            body: {
              'success' => true,
              'rates' => {
                'USD' => 1.0,
                target_currency => 0.85
              }
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns the correct exchange rate' do
        rate = ExchangeRateService.get_rate(target_currency)
        expect(rate).to eq(0.85 / 1.0)
      end
    end

    context 'when API returns an error' do
      before do
        stub_request(:get, url)
          .to_return(
            status: 200,
            body: {
              'success' => false,
              'error' => { 'info' => 'Invalid API key' }
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'logs the error and returns 1.0' do
        expect(Rails.logger).to receive(:error).with(/Exchange Rate API Error/)
        rate = ExchangeRateService.get_rate(target_currency)
        expect(rate).to eq(1.0)
      end
    end

    context 'when an exception is raised' do
      before do
        allow(Net::HTTP).to receive(:get).and_raise(StandardError.new('Network error'))
      end

      it 'logs the error and returns 1.0' do
        expect(Rails.logger).to receive(:error).with(/Exchange Rate Service Error/)
        rate = ExchangeRateService.get_rate(target_currency)
        expect(rate).to eq(1.0)
      end
    end

    context 'when API returns invalid JSON' do
      before do
        stub_request(:get, url)
          .to_return(
            status: 200,
            body: 'Invalid JSON',
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'handles the JSON parsing error and returns 1.0' do
        expect(Rails.logger).to receive(:error).with(/Exchange Rate Service Error/)
        rate = ExchangeRateService.get_rate(target_currency)
        expect(rate).to eq(1.0)
      end
    end
  end
end
