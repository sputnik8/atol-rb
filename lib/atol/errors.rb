# frozen_string_literal: true

module Atol
  class MissingConfigError < StandardError; end
  class AuthBadRequestError < StandardError; end
  class AuthUserOrPasswordError < StandardError; end
  class ConfigExpectedError < StandardError; end
  class UnknownOperationError < StandardError; end
  class BadJSONError < StandardError; end
  class IncomingOperationNotSupportError < StandardError; end
  class IncomingMissingTokenError < StandardError; end
  class IncomingExpiredTokenError < StandardError; end
  class IncomingExistExternalIdError < StandardError; end
  class GroupCodeToTokenError < StandardError; end
  class EmptyClientContactError < StandardError; end
  class EmptySellItemsError < StandardError; end
  class IncomingValidationError < StandardError; end
  class StateMissingUuidError < StandardError; end
  class StateNotFoundError < StandardError; end
  class ZeroItemQuantityError < StandardError; end

  ERRORS = Hash[
      0 => BadJSONError,
      10 => IncomingMissingTokenError,
      11 => IncomingExpiredTokenError,
      20 => GroupCodeToTokenError,
      30 => StateMissingUuidError,
      31 => IncomingOperationNotSupportError,
      32 => IncomingValidationError,
      33 => IncomingExistExternalIdError,
      34 => StateNotFoundError,
      -3804 => ZeroItemQuantityError
  ].freeze
end
