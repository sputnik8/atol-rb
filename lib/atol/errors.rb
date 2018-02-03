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
  class IncomingQueueTimeoutError < StandardError; end
  class IncomingValidationError < StandardError; end
  class IncomingQueueError < StandardError; end
  class StateBadRequestError < StandardError; end
  class StateMissingTokenError < StandardError; end
  class StateNotExistTokenError < StandardError; end
  class StateExpiredTokenError < StandardError; end
  class StateMissingUuidError < StandardError; end
  class StateNotFoundError < StandardError; end

  ERRORS = Hash[
      1 =>  BadJSONError,
      2 =>  IncomingBadRequestError,
      3 =>  IncomingOperationNotSupportError,
      4 =>  IncomingMissingTokenError,
      5 =>  IncomingNotExistTokenError,
      6 =>  IncomingExpiredTokenError,
      7 =>  IncomingQueueTimeoutError,
      8 =>  IncomingValidationError,
      9 =>  IncomingQueueError,
      10 => IncomingExistExternalIdError,
      11 => StateBadRequestError,
      12 => StateMissingTokenError,
      13 => StateNotExistTokenError,
      14 => StateExpiredTokenError,
      15 => StateMissingUuidError,
      16 => StateNotFoundError,
      22 => GroupCodeToTokenError,
      23 => IsNullExternalIdError
  ].freeze
end
