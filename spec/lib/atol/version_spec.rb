# frozen_string_literal: true

require './lib/atol/version'

RSpec.describe Atol::Version do
  it { expect(Atol::Version::V4).to eq('https://online.atol.ru/possystem/v4') }
  it { expect(Atol::Version::V5).to eq('https://online.atol.ru/possystem/v5') }

  it { expect(Atol::Version::V4_TEST).to eq('https://testonline.atol.ru/possystem/v4') }
  it { expect(Atol::Version::V5_TEST).to eq('https://testonline.atol.ru/possystem/v5') }

  it { expect(Atol::Version::LIB).to eq('1.2.0') }
end
