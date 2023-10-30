# frozen_string_literal: true

require './lib/atol/request/post_document/item/body'

RSpec.describe Atol::Request::PostDocument::Item::Body do
  let(:params) do
    Hash[
      name: 'item name',
      price: 100,
      quantity: 2,
      config: Atol::Config::Factory.example,
      payment_method: 'full_payment',
      payment_object: 'service',
      agent_info_type: 'agent',
      supplier_info_inn: '10101964',
      supplier_info_name: "ООО 'Моя Оборона'"
    ]
  end

  let(:body_hash) { described_class.new(params).to_h }

  it 'inject name' do
    expect(body_hash[:name]).to eql 'item name'
  end

  it 'inject price and make it float' do
    expect(body_hash[:price]).to eql 100.0
  end

  it 'inject qunatity and make it float' do
    expect(body_hash[:quantity]).to eql 2.0
  end

  it 'injects payment_method' do
    expect(body_hash[:payment_method]).to eql 'full_payment'
  end

  it 'injects payment_object' do
    expect(body_hash[:payment_object]).to eql 'service'
  end

  it 'calculate sum in float' do
    expect(body_hash[:sum]).to eql 200.0
  end

  it 'inject config default tax' do
    expect(body_hash[:tax]).to eql :example_default_tax
  end

  it 'inject agent type' do
    expect(body_hash[:agent_info][:type]).to eql 'agent'
  end

  it 'inject supplier inn' do
    expect(body_hash[:supplier_info][:inn]).to eql '10101964'
  end

  it 'inject supplier name' do
    expect(body_hash[:supplier_info][:name]).to eql "ООО 'Моя Оборона'"
  end

  context 'when quantity is 0' do
    before do
      params[:quantity] = 0
    end

    it 'raise Atol::ZeroItemQuantityError' do
      expect { body_hash }.to raise_error(Atol::ZeroItemQuantityError)
    end
  end

  context 'when quantity less then 1 and more then 0' do
    before do
      params[:quantity] = 0.4
    end

    it 'injects quantity' do
      expect(body_hash[:quantity]).to eql 0.4
    end
  end

  context 'when bad payment_method given' do
    before { params[:payment_method] = 'bad payment method' }

    it 'raise error' do
      expect { body_hash }.to raise_error(
        Atol::Request::PostDocument::Item::Body::BadPaymentMethodError
      )
    end
  end

  context 'when bad payment_object given' do
    before { params[:payment_object] = 'bad payment object' }

    it 'raise error' do
      expect { body_hash }.to raise_error(
        Atol::Request::PostDocument::Item::Body::BadPaymentObjectError
      )
    end
  end
end
