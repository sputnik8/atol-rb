require './lib/atol/version'

describe Atol::Version do
  it { expect(Atol::Version).to be_a Module }
  it('API eql v4') { expect(Atol::Version::API).to eql 'v4' }
  it('LIB eql 0.4.1') { expect(Atol::Version::LIB).to eql '0.4.1' }
end
