# frozen_string_literal: true

require './lib/atol/request/post_document'

describe Atol::Request::PostDocument do
  it { expect(described_class).to be_a Class }

  let(:config) do
    Atol::Config.new(overrides: {
      group_code: 'group_code_example',
      http_client: Net::HTTP
    })
  end

  let(:token) { 'token_example' }
  let(:body) { '{"json": "example"}' }
  let(:base_params) { Hash[token: token, body: body, config: config] }

  describe '#new' do
    context 'when given existing operation' do
      it 'sell' do
        params = base_params.merge(operation: 'sell')
        expect { described_class.new(params) }.not_to raise_error
      end

      it 'sell_refund' do
        params = base_params.merge(operation: 'sell_refund')
        expect { described_class.new(params) }.not_to raise_error
      end

      it 'sell_correction' do
        params = base_params.merge(operation: 'sell_correction')
        expect { described_class.new(params) }.not_to raise_error
      end

      it 'buy' do
        params = base_params.merge(operation: 'buy')
        expect { described_class.new(params) }.not_to raise_error
      end

      it 'buy_refund' do
        params = base_params.merge(operation: 'buy_refund')
        expect { described_class.new(params) }.not_to raise_error
      end

      it 'buy_correction' do
        params = base_params.merge(operation: 'buy_correction')
        expect { described_class.new(params) }.not_to raise_error
      end
    end

    context 'when given not existing operation' do
      let(:not_existing_operation) { :kill_all_humans }
      let(:params) { base_params.merge(operation: not_existing_operation) }
      it { expect { described_class.new(params) }.to raise_error(Atol::UnknownOperationError) }
    end
  end

  describe '#call' do
    before do
      stub_request(:post, 'https://online.atol.ru/possystem/v4/group_code_example/sell')
        .with(headers: { 'Content-Type' => 'application/json; charset=utf-8', 'Token' => 'token_example' })
        .to_return(status: 200, body: '', headers: {})
    end

    it 'return result of http request' do
      params = base_params.merge(operation: :sell)
      request = described_class.new(params)
      response = request.call
      expect(response.code).to eql '200'
    end

    it 'calls loggers for request and response' do
      req_logger_flag = 'not called'
      res_logger_flag = 'not called'

      req_logger = ->(req) { req_logger_flag = req }
      res_logger = ->(res) { res_logger_flag = res }

      params = base_params.merge(
        operation: :sell,
        req_logger: req_logger,
        res_logger: res_logger
      )

      request = described_class.new(params)
      request.call

      expect(req_logger_flag).not_to eql 'not_called'
      expect(res_logger_flag).not_to eql 'not_called'
    end
  end
end
