require './lib/atol/errors'

describe Atol::MissingConfigError do
  it { expect(Atol::MissingConfigError).to be_a Class }
end
