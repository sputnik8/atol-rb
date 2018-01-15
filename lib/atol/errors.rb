module Atol
  class MissingConfigError < StandardError; end
  class AuthBadRequestError < StandardError; end
  class AuthUserOrPasswordError < StandardError; end
  class ConfigExpectedError < StandardError; end
end
