# frozen_string_literal: true

require './lib/atol/transaction/post_document'

describe Atol::Transaction::PostDocument do
  let(:config) { Atol::Config::Factory.example }
  let(:token_string) { 'example_token_string' }

  it { expect(described_class).to be_a Class }

  describe '#new' do
    context 'with arguments' do
      let(:params) { Hash[operation: :sell, token: token_string, body: '', config: config] }
      it { expect { described_class.new(params) }.not_to raise_error }
    end

    context 'with bad config' do
      let(:params) { Hash[operation: :sell, token: token_string, body: '', config: 1] }
      let(:error) { Atol::ConfigExpectedError }
      it { expect { described_class.new(params) }.to raise_error(error) }
    end
  end

  describe '#call' do
    let(:url) { 'https://online.atol.ru/possystem/v4/example_group_code/sell' }
    let(:params) do
      Hash[operation: :sell, token: token_string, body: '', config: config]
    end
    let(:transaction) { described_class.new(params) }

    context 'when response is 200' do
      before do
        stub_request(:post, url).to_return({
          status: 200,
          headers: {},
          body: '{
            "uuid": "2ea26f17-0884-4f08-b120-306fc096a58f"
          }'
        })
      end

      it 'returns response body' do
        response_body = transaction.call
        expect(response_body['uuid']).to eql('2ea26f17-0884-4f08-b120-306fc096a58f')
      end
    end

    context 'when response is 400' do
      context 'when error code is 0' do
        before do
          stub_request(:post, url).to_return({
            status: 400,
            headers: {},
            body: '{
              "error": {
                "code": 0,
                "text": "errortext"
              }
            }'
          })
        end

        it do
          expect { transaction.call }.to raise_error(Atol::BadJSONError)
        end
      end

      context 'when error code is 31' do
        before do
          stub_request(:post, url).to_return({
            status: 400,
            headers: {},
            body: '{
              "error": {
                "code": 31,
                "text": "errortext"
              }
            }'
          })
        end

        it do
          expect { transaction.call }.to raise_error(Atol::IncomingOperationNotSupportError)
        end
      end

      context 'when error code is 10' do
        before do
          stub_request(:post, url).to_return({
            status: 400,
            headers: {},
            body: '{
              "error": {
                "code": 10,
                "text": "errortext"
              }
            }'
          })
        end

        it do
          expect { transaction.call }.to raise_error(Atol::IncomingMissingTokenError)
        end
      end

      context 'when error code is 33' do
        before do
          stub_request(:post, url).to_return({
            status: 400,
            headers: {},
            body: '{
              "error": {
                "code": 33,
                "text": "errortext"
              }
            }'
          })
        end

        it do
          expect { transaction.call }.to raise_error(Atol::IncomingExistExternalIdError)
        end
      end

      context 'when error code is 20' do
        before do
          stub_request(:post, url).to_return({
            status: 400,
            headers: {},
            body: '{
              "error": {
                "code": 20,
                "text": "errortext"
              }
            }'
          })
        end

        it do
          expect { transaction.call }.to raise_error(Atol::GroupCodeToTokenError)
        end
      end
    end

    context 'when response is 401' do
      context 'when error code is 11' do
        before do
          stub_request(:post, url).to_return({
            status: 401,
            headers: {},
            body: '{
              "error": {
                "code": 11,
                "text": "errortext"
              }
            }'
          })
        end

        it do
          expect { transaction.call }.to raise_error(Atol::IncomingExpiredTokenError)
        end
      end
    end
  end
end
