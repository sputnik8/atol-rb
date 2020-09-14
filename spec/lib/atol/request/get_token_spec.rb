# frozen_string_literal: true

require './lib/atol/request/get_token'

RSpec.describe Atol::Request::GetToken do
  describe '#new' do
    context 'raise error when config missing' do
      before { allow(Atol.config).to receive(:login).and_return(nil) }
      let(:error) { Atol::MissingConfigError }
      it { expect { described_class.new }.to raise_error(error) }
    end

    context 'not raise error when there is full config' do
      before { allow(Atol.config).to receive(:login).and_return('log') }
      before { allow(Atol.config).to receive(:password).and_return('pass') }
      it { expect { described_class.new }.not_to raise_error }
    end
  end

  describe '#call return result of http request' do
    before do
      stub_request(:get, 'https://online.atol.ru/possystem/v4/getToken?login=log&pass=pass')
        .to_return(status: 200, body: 'result', headers: {})

      allow(Atol.config).to receive(:login).and_return('log')
      allow(Atol.config).to receive(:password).and_return('pass')
      allow(Atol.config).to receive(:http_client).and_return(Net::HTTP)
    end

    it { expect(described_class.new.call.body).to eql 'result' }
  end
end
