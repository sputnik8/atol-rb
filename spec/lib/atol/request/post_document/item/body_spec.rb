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
      payment_object: 'service'
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

  it 'does not inject agent_type' do
    expect(body_hash.keys.include?(:agent_info)).to eq false
  end

  it 'does not inject supplier_info' do
    expect(body_hash.keys.include?(:supplier_info)).to eq false
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

  context 'when there is agent_type and supplier_info in params' do
    let(:agent_type) { 'paying_agent' }
    let(:supplier_phones) { ['9251234567', '+7925 1234567'] }
    let(:supplier_name) { 'supplier name' }
    let(:supplier_inn) { '1234567890' }

    before do
      params.merge!(
        agent_type: agent_type,
        supplier_phones: supplier_phones,
        supplier_name: supplier_name,
        supplier_inn: supplier_inn
      )
    end

    it 'injects agent_type' do
      expect(body_hash[:agent_info][:type]).to eql agent_type
      expect(body_hash[:supplier_info][:phones]).to eql supplier_phones
      expect(body_hash[:supplier_info][:name]).to eql supplier_name
      expect(body_hash[:supplier_info][:inn]).to eql supplier_inn
    end
  end

  context 'when bad agent_type given' do
    before { params[:agent_type] = 'bad agent type' }

    it 'raise error' do
      expect { body_hash }.to raise_error(
        Atol::Request::PostDocument::Item::Body::BadAgentTypeError
      )
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
