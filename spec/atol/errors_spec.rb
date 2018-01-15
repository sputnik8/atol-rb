require './lib/atol/errors'

describe Atol::MissingConfigError do
  it { expect(Atol::MissingConfigError).to be_a Class }
  it { expect(Atol::ConfigExpectedError).to be_a Class }
  it { expect(Atol::AuthBadRequestError).to be_a Class }
  it { expect(Atol::AuthUserOrPasswordError).to be_a Class }
end
