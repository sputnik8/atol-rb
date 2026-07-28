# frozen_string_literal: true

require './lib/atol'
require './lib/atol/request/post_document/correction/v5/body'

RSpec.describe Atol::Request::PostDocument::Correction::V5::Body do
  subject(:body) { described_class.new(**params) }

  let(:params) do
    {
      external_id: external_id,
      email: email,
      items: items,
      payments: payments,
      correction_type: correction_type,
      base_date: base_date,
      base_number: base_number,
      config: config,
      additional_check_props: additional_check_props
    }
  end
  let(:external_id) { '123' }
  let(:email) { 'client@example.com' }
  let(:items) { [{ sum: 10 }, { sum: 5 }] }
  let(:payments) { [Atol::Request::PostDocument::Payment.new(type: 2, sum: 15.0)] }
  let(:correction_type) { 'self' }
  let(:base_date) { '01.01.2026' }
  let(:base_number) { '12345' }
  let(:additional_check_props) { 'ФПД123456' }
  let(:config) { Atol::Config::Factory.example }

  describe '#new' do
    it { is_expected.to be_a(described_class) }

    context 'when both phone and email are empty' do
      let(:email) { '' }

      it 'raises EmptyClientContactError' do
        expect { body }.to raise_error(Atol::EmptyClientContactError)
      end
    end

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

    context 'when base number is longer than 32 bytes' do
      let(:base_number) { 'x' * 33 }

      it 'raises BadCorrectionBaseNumberError' do
        expect { body }.to raise_error(described_class::BadCorrectionBaseNumberError)
      end
    end

    context 'when additional_check_props is longer than 16 bytes' do
      let(:additional_check_props) { 'x' * 17 }

      it 'raises BadAdditionalCheckPropsError' do
        expect { body }.to raise_error(described_class::BadAdditionalCheckPropsError)
      end
    end

    context 'when additional_check_props exceeds 16 bytes with multibyte characters' do
      let(:additional_check_props) { 'ЁЁЁЁЁЁЁЁЁ' }

      it 'raises BadAdditionalCheckPropsError' do
        expect { body }.to raise_error(described_class::BadAdditionalCheckPropsError)
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

    context 'when payments sum does not match items total' do
      let(:payments) { [Atol::Request::PostDocument::Payment.new(type: 2, sum: 99.0)] }

      it 'raises PaymentsTotalMismatchError' do
        expect { body }.to raise_error(Atol::PaymentsTotalMismatchError)
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
            client: { email: 'client@example.com' },
            company: {
              inn: 'example_inn',
              sno: :example_default_sno,
              payment_address: :example_payment_address,
              email: nil
            },
            correction_info: { type: 'self', base_date: '01.01.2026', base_number: '12345' },
            items: [{ sum: 10 }, { sum: 5 }],
            payments: [{ type: 2, sum: 15.0 }],
            total: 15,
            internet: false,
            additional_check_props: 'ФПД123456'
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

    context 'when a phone is passed' do
      let(:params) { super().merge(phone: '+79161234567') }

      it 'puts the phone into the client block' do
        expect(body_hash[:correction][:client]).to eq(email: 'client@example.com', phone: '+79161234567')
      end
    end

    context 'when internet is enabled in config' do
      let(:config) do
        Atol::Config::Factory.example.tap { |example| example.internet = true }
      end

      it 'reflects config.internet in the correction body' do
        expect(body_hash[:correction][:internet]).to be true
      end
    end

    context 'when additional_check_props is not passed' do
      let(:additional_check_props) { nil }

      it 'omits additional_check_props from the correction body' do
        expect(body_hash[:correction]).not_to have_key(:additional_check_props)
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
