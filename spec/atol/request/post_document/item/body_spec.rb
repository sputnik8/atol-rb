require './lib/atol/request/post_document/item/body'

describe Atol::Request::PostDocument::Item::Body do
  it { expect(described_class).to be_a Class }

  let(:params) { Hash[
      name: 'item name',
      price: 100,
      quantity: 2,
      config: Atol::Config::Factory.example
  ]}

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


  it 'calculate sum in float' do
    expect(body_hash[:sum]).to eql 200.0
  end

  it 'inject config default tax' do
    expect(body_hash[:tax]).to eql :example_default_tax
  end

  context 'when quantity is 0' do
    before do
      params[:quantity] = 0
    end

    it 'raise Atol::ZeroItemQuantityError' do
      expect { body_hash }.to raise_error(Atol::ZeroItemQuantityError)
    end
  end
end
