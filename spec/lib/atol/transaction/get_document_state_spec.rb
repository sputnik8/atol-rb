# frozen_string_literal: true

require 'webmock/rspec'
require './lib/atol/transaction/get_document_state'

RSpec.describe Atol::Transaction::GetDocumentState do
  let(:uuid) { 'example_uuid' }
  let(:config) { Atol::Config::Factory.example }
  let(:token_string) { 'example_token' }

  describe '#new' do
    context 'with arguments' do
      let(:params) { Hash[uuid: uuid, token: token_string, config: config] }
      it { expect { described_class.new(params) }.not_to raise_error }
    end

    context 'with bad config' do
      let(:params) { Hash[uuid: uuid, token: token_string, config: 1] }
      let(:error) { Atol::ConfigExpectedError }
      it { expect { described_class.new(params) }.to raise_error(error) }
    end
  end

  describe '#call' do
    let(:url) do
      'https://online.atol.ru/possystem/v5/example_group_code/report/example_uuid'
    end

    let(:params) do
      Hash[uuid: uuid, token: token_string, config: config]
    end

    let(:transaction) { described_class.new(params) }

    context 'when response is 200 without error' do
      before do
        stub_request(:get, url)
          .with(headers: { 'Token' => token_string })
          .to_return(
            status: 200,
            headers: {},
            body: { uuid: uuid, error: nil }.to_json
          )

        allow(Atol.config).to receive(:http_client).and_return(Net::HTTP)
      end

      it 'returns response body' do
        response_body = transaction.call
        expect(response_body['uuid']).to eql uuid
      end
    end

    context 'when response is 400 with error 32' do
      before do
        stub_request(:get, url)
          .with(headers: { 'Token' => token_string })
          .to_return(
            status: 400,
            headers: {},
            body: {
              uuid: uuid,
              error: {
                code: 32
              }
            }.to_json
          )
        allow(Atol.config).to receive(:http_client).and_return(Net::HTTP)
      end

      it 'returns response body' do
        expect { transaction.call }.to raise_error Atol::IncomingValidationError
      end
    end
  end
end
