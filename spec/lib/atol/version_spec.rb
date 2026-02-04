# frozen_string_literal: true

require './lib/atol/version'

RSpec.describe Atol::Version do
  it { expect(Atol::Version::LIB).to eq('1.1.0') }
end
