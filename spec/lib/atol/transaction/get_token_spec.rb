# frozen_string_literal: true

require 'webmock/rspec'
require './lib/atol/transaction/get_token'

describe Atol::Transaction::GetToken do
  it { expect(described_class).to be_a Class }

  describe '#new' do
    context 'without arguments' do
      it { expect { described_class.new }.not_to raise_error }
    end

    context 'with good argument' do
      let(:config) { Atol::Config.new }
      it { expect { described_class.new(config: config) }.not_to raise_error }
    end

    context 'with bad argument' do
      let(:error) { Atol::ConfigExpectedError }
      it { expect { described_class.new(config: 1) }.to raise_error(error) }
    end
  end

  describe '#call' do
    let(:config) do
      Atol::Config.new(overrides: {
        login: 'example_login',
        password: 'example_password',
        http_client: Net::HTTP
      })
    end

    context 'when response is 200' do
      let(:token_string) { 'example_token_string' }

      before do
        stub_request(:get, /online.atol.ru/).to_return({
          status: 200,
          headers: {},
          body: { token: token_string }.to_json
        })
      end

      it 'returns token string' do
        transaction = described_class.new(config: config)
        expect(transaction.call).to eql(token_string)
      end
    end

    context 'when response code is 400' do
      before do
        stub_request(:get, /online.atol.ru/).to_return({
          status: 400,
          headers: {},
          body: { code: 17 }.to_json
        })
        allow(Atol.config).to receive(:http_client).and_return(Net::HTTP)
      end

      it do
        transaction = described_class.new(config: config)
        expect { transaction.call }.to raise_error Atol::AuthBadRequestError
      end
    end

    context 'when response code is 401' do
      before do
        stub_request(:get, /online.atol.ru/).to_return({
          status: 401,
          headers: {},
          body: {}.to_json
        })
        allow(Atol.config).to receive(:http_client).and_return(Net::HTTP)
      end

      it do
        transaction = described_class.new(config: config)
        expect { transaction.call }.to raise_error Atol::AuthUserOrPasswordError
      end
    end

    context 'when response code 415' do
      before do
        stub_request(:get, /online.atol.ru/).to_return({
          status: 415,
          headers: {},
          body: {}.to_json
        })
        allow(Atol.config).to receive(:http_client).and_return(Net::HTTP)
      end

      it do
        transaction = described_class.new(config: config)
        expect { transaction.call }.to raise_error RuntimeError
      end
    end
  end
end
