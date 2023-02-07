# frozen_string_literal: true

require 'net/http'
require './lib/atol/request/get_document_state'

RSpec.describe Atol::Request::GetDocumentState do
  describe '#new' do
    before { allow(Atol.config).to receive(:group_code).and_return(nil) }
    let(:request) { described_class.new(uuid: '123', token: '456') }

    it 'raise error when config missing' do
      expect { request.call }.to raise_error(Atol::MissingConfigError)
    end
  end

  describe '#call return result of http request' do
    before do
      stub_request(:get, 'https://online.atol.ru/possystem/v5/123456/report/123')
        .with(headers: { 'Token' => '456' })
        .to_return(status: 200, body: 'result', headers: {})

      allow(Atol.config).to receive(:group_code).and_return('123456')
      allow(Atol.config).to receive(:http_client).and_return(Net::HTTP)
    end

    let(:request) { described_class.new(uuid: '123', token: '456') }

    it { expect(request.call.body).to eql 'result' }
  end
end
