require './lib/atol/config'

describe Atol::Config do
  it { expect(Atol::Config).to be_a Class }

  #describe 'URL' do
  #  let(:correct) { 'https://online.atol.ru/possystem/v3' }
  #  it { expect(Atol::URL).to eql correct }
  #end
#
  #describe 'ENCODING' do
  #  it { expect(Atol::ENCODING).to eql 'utf-8' }
  #end
end
