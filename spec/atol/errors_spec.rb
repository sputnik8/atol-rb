require './lib/atol/errors'

describe Atol::MissingConfigError do
  it { expect(Atol::MissingConfigError).to be_a Class }
end
describe Atol::ConfigExpectedError do
  it { expect(Atol::ConfigExpectedError).to be_a Class }
end
describe Atol::AuthBadRequestError do
  it { expect(Atol::AuthBadRequestError).to be_a Class }
end
describe Atol::AuthUserOrPasswordError do
  it { expect(Atol::AuthUserOrPasswordError).to be_a Class }
end
describe Atol::UnknownOperationError do
  it { expect(Atol::UnknownOperationError).to be_a Class }
end
