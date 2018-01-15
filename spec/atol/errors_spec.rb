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
describe Atol::BadJSONError do
  it { expect(Atol::BadJSONError).to be_a Class }
end
describe Atol::IncomingBadRequestError do
  it { expect(Atol::IncomingBadRequestError).to be_a Class }
end
describe Atol::IncomingOperationNotSupportError do
  it { expect(Atol::IncomingOperationNotSupportError).to be_a Class }
end
describe Atol::IncomingMissingTokenError do
  it { expect(Atol::IncomingMissingTokenError).to be_a Class }
end
describe Atol::IncomingNotExistTokenError do
  it { expect(Atol::IncomingNotExistTokenError).to be_a Class }
end
describe Atol::IncomingExpiredTokenError do
  it { expect(Atol::IncomingExpiredTokenError).to be_a Class }
end
describe Atol::IncomingExistExternalIdError do
  it { expect(Atol::IncomingExistExternalIdError).to be_a Class }
end
describe Atol::GroupCodeToTokenError do
  it { expect(Atol::GroupCodeToTokenError).to be_a Class }
end
describe Atol::IsNullExternalIdError do
  it { expect(Atol::IsNullExternalIdError).to be_a Class }
end
