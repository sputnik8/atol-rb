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
      it { expect { described_class.new(params) }.to raise_error(error)  }
    end
  end

  describe '#call' do
    let(:url) { 'https://online.atol.ru/possystem/v3/example_group_code/sell?tokenid=example_token_string' }
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

    context 'when response is 200 and error 23' do
      before do
        stub_request(:post, url).to_return({
          status: 200,
          headers: {},
          body: '{
            "error": {
              "code": 23,
              "text": "errortext"
            }
          }'
        })
      end

      it do
        expect { transaction.call }.to raise_error(Atol::IsNullExternalIdError)
      end
    end

    context 'when response is 400' do
      context 'when error code is 1' do
        before do
          stub_request(:post, url).to_return({
            status: 400,
            headers: {},
            body: '{
              "error": {
                "code": 1,
                "text": "errortext"
              }
            }'
          })
        end

        it do
          expect { transaction.call }.to raise_error(Atol::BadJSONError)
        end
      end

      context 'when error code is 2' do
        before do
          stub_request(:post, url).to_return({
            status: 400,
            headers: {},
            body: '{
              "error": {
                "code": 2,
                "text": "errortext"
              }
            }'
          })
        end

        it do
          expect { transaction.call }.to raise_error(Atol::IncomingBadRequestError)
        end
      end

      context 'when error code is 3' do
        before do
          stub_request(:post, url).to_return({
            status: 400,
            headers: {},
            body: '{
              "error": {
                "code": 3,
                "text": "errortext"
              }
            }'
          })
        end

        it do
          expect { transaction.call }.to raise_error(Atol::IncomingOperationNotSupportError)
        end
      end

      context 'when error code is 4' do
        before do
          stub_request(:post, url).to_return({
            status: 400,
            headers: {},
            body: '{
              "error": {
                "code": 4,
                "text": "errortext"
              }
            }'
          })
        end

        it do
          expect { transaction.call }.to raise_error(Atol::IncomingMissingTokenError)
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
          expect { transaction.call }.to raise_error(Atol::IncomingExistExternalIdError)
        end
      end

      context 'when error code is 22' do
        before do
          stub_request(:post, url).to_return({
            status: 400,
            headers: {},
            body: '{
              "error": {
                "code": 22,
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
      context 'when error code is 5' do
        before do
          stub_request(:post, url).to_return({
            status: 401,
            headers: {},
            body: '{
              "error": {
                "code": 5,
                "text": "errortext"
              }
            }'
          })
        end

        it do
          expect { transaction.call }.to raise_error(Atol::IncomingNotExistTokenError)
        end
      end

      context 'when error code is 6' do
        before do
          stub_request(:post, url).to_return({
            status: 401,
            headers: {},
            body: '{
              "error": {
                "code": 6,
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
