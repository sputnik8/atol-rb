require './lib/atol/request/post_document/sell/body'

describe Atol::Request::PostDocument::Sell::Body do
  it { expect(described_class).to be_a Class }

  describe '#new' do
    it 'raise error when contacts empty' do
      params = Hash[external_id: '123456', items: [1, 2, 3]]
      expect { described_class.new(params) }.to raise_error(Atol::EmptyClientContactError)
    end

    it 'raise error when items empty' do
      params = Hash[external_id: '123456', phone: '123456789', items: []]
      expect { described_class.new(params) }.to raise_error(Atol::EmptySellItemsError)
    end
  end

  describe '#to_h' do
    let(:timestamp) { Time.now }
    let(:params) { Hash[
      external_id: '123',
      phone: '123456',
      email: 'email@example.com',
      items: [{ sum: 10 }, { sum: 5 }],
      config: Atol::Config::Factory.example
    ]}

    before { allow(Time).to receive(:now).and_return(timestamp) }

    let(:body_hash) { described_class.new(params).to_h }

    describe 'injects config variables' do
      it 'sno' do
        expect(body_hash[:receipt][:attributes][:sno]).to eql :example_default_sno
      end

      it 'payments type' do
        expect(body_hash[:receipt][:payments][0][:type]).to eql 1
      end

      it 'items' do
        expect(body_hash[:receipt][:items]).to eql params[:items]
      end

      it 'inn' do
        expect(body_hash[:service][:inn]).to eql :example_inn
      end

      it 'payment address' do
        expect(body_hash[:service][:payment_address]).to eql :example_payment_address
      end
    end

    describe 'injects document params' do
      it 'example_id' do
        expect(body_hash[:external_id]).to eql '123'
      end

      it 'contact phone' do
        expect(body_hash[:receipt][:attributes][:phone]).to eql '123456'
      end

      it 'contact email' do
        expect(body_hash[:receipt][:attributes][:email]).to eql 'email@example.com'
      end
    end

    describe 'calculate sum' do
      it 'payments sum' do
        expect(body_hash[:receipt][:payments][0][:sum]).to eql 15
      end

      it 'total' do
        expect(body_hash[:receipt][:total]).to eql 15
      end
    end

    it 'format timestamp' do
      expect(body_hash[:timestamp]).to eql timestamp.strftime('%d.%m.%Y %H:%M:%S')
    end

    it 'not inject empty key when callback_url is empty' do
      expect(body_hash[:service].keys).not_to include :callback_url
    end

    it 'inject callback_url when it exist' do
      params[:config].callback_url = 'url'
      expect(body_hash[:service].keys).to include :callback_url
      expect(body_hash[:service][:callback_url]).to eql 'url'
    end
  end
end
