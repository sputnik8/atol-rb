require 'net/http'
require './lib/atol/request/get_token'

describe Atol::Request::GetToken do
  it { expect(Atol::Request::GetToken).to be_a Class }

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
    before { allow(Atol.config).to receive(:login).and_return('log') }
    before { allow(Atol.config).to receive(:password).and_return('pass') }
    before { allow(Net::HTTP).to receive(:get_response).and_return('result') }

    it { expect(described_class.new.call).to eql 'result' }
  end
end
