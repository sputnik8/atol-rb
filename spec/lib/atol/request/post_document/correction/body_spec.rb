# frozen_string_literal: true

require './lib/atol'
require './lib/atol/request/post_document/correction/body'
require './lib/atol/request/post_document/correction/v5/body'

RSpec.describe Atol::Request::PostDocument::Correction::Body, aggregate_failures: true do
  subject(:new) { described_class.new(**params) }

  let(:config) do
    config = Atol::Config::Factory.example
    config.api_url = api_url
    config
  end
  let(:params) do
    {
      config: config,
      external_id: '123',
      email: 'client@example.com',
      items: [{ sum: 10 }],
      payments: [Atol::Request::PostDocument::Payment.new(type: 2, sum: 10.0)],
      correction_type: 'self',
      base_date: '01.01.2026'
    }
  end

  context 'when v5 version' do
    let(:api_url) { Atol::Version::V5 }

    it { expect { new }.not_to raise_error }
    it { expect(new.instance).to be_a(Atol::Request::PostDocument::Correction::V5::Body) }
    it { expect { new.to_h }.not_to raise_error }
    it { expect { new.to_json }.not_to raise_error }
  end

  context 'when v5 test version' do
    let(:api_url) { Atol::Version::V5_TEST }

    it { expect(new.instance).to be_a(Atol::Request::PostDocument::Correction::V5::Body) }
  end

  context 'when v4 version' do
    let(:api_url) { Atol::Version::V4 }

    it 'raises BadApiUrlError because the v4 correction body is not implemented' do
      expect { new }.to raise_error(described_class::BadApiUrlError, 'correction body for the v4 api is not implemented')
    end
  end

  context 'when v4 test version' do
    let(:api_url) { Atol::Version::V4_TEST }

    it { expect { new }.to raise_error(described_class::BadApiUrlError, 'correction body for the v4 api is not implemented') }
  end

  context 'when api_url is unknown' do
    let(:api_url) { 'https://example.com/possystem/v9' }

    it { expect { new }.to raise_error(described_class::BadApiUrlError) }
  end
end
