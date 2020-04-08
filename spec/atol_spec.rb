# frozen_string_literal: true

require './lib/atol'

describe Atol do
  it { expect(Atol).to be_a Module }

  describe 'ENCODING' do
    it { expect(Atol::ENCODING).to eql 'utf-8' }
  end

  describe 'self#config' do
    it 'has default Atol::Config object' do
      expect(Atol.config).to be_a Atol::Config
    end
  end

  describe 'self#config=' do
    it 'set new config' do
      Atol.config = :example
      expect(Atol.config).to eql :example
    end
  end
end
