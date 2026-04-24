# frozen_string_literal: true

RSpec.describe Atol::Request::PostDocument::Item::Body, aggregate_failures: true do
  subject(:new) { described_class.new(**params) }

  let(:config) do
    config = Atol::Config::Factory.example
    config.api_url = api_url
    config
  end

  context 'when v4 version' do
    let(:params) do
      {
        config: config,
        name: 'Activity',
        price: 42.0,
        payment_method: 'prepayment',
        payment_object: 'service'
      }
    end
    let(:api_url) { 'https://online.atol.ru/possystem/v4' }

    it { expect { new }.not_to raise_error }
    it { expect(new.instance).to be_a(Atol::Request::PostDocument::Item::V4::Body) }
    it { expect { new.to_h }.not_to raise_error }
  end

  context 'when v5 version' do
    let(:params) do
      {
        config: config,
        name: 'Activity',
        price: 42.0,
        payment_method: 'prepayment',
        payment_object: 4,
        measure: 0,
        vat: { type: 'none' }
      }
    end
    let(:api_url) { 'https://online.atol.ru/possystem/v5' }

    it { expect { new }.not_to raise_error }
    it { expect(new.instance).to be_a(Atol::Request::PostDocument::Item::V5::Body) }
    it { expect { new.to_h }.not_to raise_error }
  end
end