# frozen_string_literal: true

require './lib/atol'
require './lib/atol/request/post_document/correction/body'

RSpec.describe Atol::Request::PostDocument::Correction::Body do
  subject(:body) { described_class.new(**params) }

  let(:params) do
    {
      external_id: external_id,
      items: items,
      payments: payments,
      correction_type: correction_type,
      base_date: base_date,
      base_number: base_number,
      config: config
    }
  end
  let(:external_id) { '123' }
  let(:items) { [{ sum: 10 }, { sum: 5 }] }
  let(:payments) { [Atol::Request::PostDocument::Payment.new(type: 2, sum: 15.0)] }
  let(:correction_type) { 'self' }
  let(:base_date) { '01.01.2026' }
  let(:base_number) { '12345' }
  let(:config) { Atol::Config::Factory.example }

  describe '#new' do
    it { is_expected.to be_a(Atol::Request::PostDocument::Correction::Body) }

    context 'when items are empty' do
      let(:items) { [] }

      it 'raises EmptySellItemsError' do
        expect { body }.to raise_error(Atol::EmptySellItemsError)
      end
    end

    context 'when correction type is unknown' do
      let(:correction_type) { 'foo' }

      it 'raises BadCorrectionTypeError' do
        expect { body }.to raise_error(described_class::BadCorrectionTypeError)
      end
    end

    context 'when base date has a wrong format' do
      let(:base_date) { '2026-01-01' }

      it 'raises BadCorrectionBaseDateError' do
        expect { body }.to raise_error(described_class::BadCorrectionBaseDateError)
      end
    end

    context 'when base number is longer than 32 characters' do
      let(:base_number) { 'x' * 33 }

      it 'raises BadCorrectionBaseNumberError' do
        expect { body }.to raise_error(described_class::BadCorrectionBaseNumberError)
      end
    end

    context 'when a payment is not a Payment instance' do
      let(:payments) { [{ type: 2, sum: 15.0 }] }

      it 'raises BadPaymentError' do
        expect { body }.to raise_error(Atol::BadPaymentError)
      end
    end

    context 'when payments is an empty array' do
      let(:payments) { [] }

      it 'raises EmptyPaymentsError' do
        expect { body }.to raise_error(Atol::EmptyPaymentsError)
      end
    end
  end

  describe '#to_h' do
    subject(:body_hash) { body.to_h }

    let(:timestamp) { Time.now }

    before { allow(Time).to receive(:now).and_return(timestamp) }

    context 'when base_number is passed' do
      it 'builds the correction body wrapped in correction with base_number' do
        is_expected.to eq(
          external_id: '123',
          correction: {
            company: {
              inn: 'example_inn',
              sno: :example_default_sno,
              payment_address: :example_payment_address,
              email: nil
            },
            correction_info: { type: 'self', base_date: '01.01.2026', base_number: '12345' },
            items: [{ sum: 10 }, { sum: 5 }],
            payments: [{ type: 2, sum: 15.0 }],
            total: 15
          },
          service: {},
          timestamp: timestamp.strftime('%d.%m.%Y %H:%M:%S')
        )
      end
    end

    context 'when base_number is not passed' do
      let(:base_number) { nil }

      it 'omits base_number from correction_info' do
        expect(body_hash[:correction][:correction_info]).to eq(type: 'self', base_date: '01.01.2026')
      end
    end

    context 'when payments are not passed' do
      let(:payments) { nil }

      it 'builds a single default payment from config with the items total' do
        expect(body_hash[:correction][:payments]).to eq([{ sum: 15, type: 1 }])
      end
    end

    context 'when callback_url is configured' do
      let(:config) do
        Atol::Config::Factory.example.tap { |example| example.callback_url = 'url' }
      end

      it 'injects callback_url into the service block' do
        expect(body_hash[:service]).to include(callback_url: 'url')
      end
    end
  end
end
