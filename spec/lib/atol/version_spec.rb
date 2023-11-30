# frozen_string_literal: true

require './lib/atol/version'

RSpec.describe Atol::Version do
  it { expect(Atol::Version::API).to eq('v4') }
  it { expect(Atol::Version::LIB).to eq('0.8.0') }
end
