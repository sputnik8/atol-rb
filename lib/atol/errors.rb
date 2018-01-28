module Atol
  class MissingConfigError < StandardError; end
  class AuthBadRequestError < StandardError; end
  class AuthUserOrPasswordError < StandardError; end
  class ConfigExpectedError < StandardError; end
  class UnknownOperationError < StandardError; end

  class BadJSONError < StandardError; end
  class IncomingBadRequestError < StandardError; end
  class IncomingOperationNotSupportError < StandardError; end
  class IncomingMissingTokenError < StandardError; end
  class IncomingNotExistTokenError < StandardError; end
  class IncomingExpiredTokenError < StandardError; end
  class IncomingExistExternalIdError < StandardError; end
  class GroupCodeToTokenError < StandardError; end
  class IsNullExternalIdError < StandardError; end

  class EmptyClientContactError < StandardError; end
  class EmptySellItemsError < StandardError; end
end
