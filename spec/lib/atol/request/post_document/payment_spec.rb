# frozen_string_literal: true

require './lib/atol/request/post_document/payment'

RSpec.describe Atol::Request::PostDocument::Payment do
  subject(:payment) { described_class.new(type: type, sum: sum) }

  let(:type) { 2 }
  let(:sum) { 15.0 }

  describe '#initialize' do
    it { is_expected.to have_attributes(type: 2, sum: 15.0) }

    context 'when type is out of range' do
      let(:type) { 10 }

      it 'raises BadPaymentError' do
        expect { payment }.to raise_error(Atol::BadPaymentError, 'not allowed type')
      end
    end

    context 'when sum is not numeric' do
      let(:sum) { '15' }

      it 'raises BadPaymentError' do
        expect { payment }.to raise_error(Atol::BadPaymentError, 'sum must be zero or a positive number')
      end
    end

    context 'when sum is negative' do
      let(:sum) { -1 }

      it 'raises BadPaymentError' do
        expect { payment }.to raise_error(Atol::BadPaymentError, 'sum must be zero or a positive number')
      end
    end

    context 'when sum is zero' do
      let(:sum) { 0 }

      it { expect { payment }.not_to raise_error }
    end
  end

  describe '#to_h' do
    subject(:to_h) { payment.to_h }

    let(:type) { 1 }
    let(:sum) { 10.0 }

    it { is_expected.to eq(sum: 10.0, type: 1) }
  end
end
