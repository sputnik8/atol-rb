require 'net/http'
require './lib/atol/request/get_document_state'

describe Atol::Request::GetDocumentState do
  it { expect(Atol::Request::GetDocumentState).to be_a Class }

  describe '#new' do
    before { allow(Atol.config).to receive(:group_code).and_return(nil) }
    let(:request) { described_class.new(uuid: '123', token: '456') }

    it 'raise error when config missing' do
      expect { request.call }.to raise_error(Atol::MissingConfigError)
    end
  end

  describe '#call return result of http request' do
    before { allow(Atol.config).to receive(:group_code).and_return('123456') }
    before { allow(Net::HTTP).to receive(:get_response).and_return('result') }

    let(:request) { described_class.new(uuid: '123', token: '456') }

    it { expect(request.call).to eql 'result' }
  end
end
