# frozen_string_literal: true

require './lib/atol/version'

describe Atol::Version do
  it { expect(Atol::Version).to be_a Module }
  it { expect(Atol::Version::API).to eq('v4') }
  it { expect(Atol::Version::LIB).to eq('0.7') }
end
