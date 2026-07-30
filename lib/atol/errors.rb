# frozen_string_literal: true

module Atol
  class MissingConfigError < StandardError; end
  class AuthBadRequestError < StandardError; end
  class AuthUserOrPasswordError < StandardError; end
  class ConfigExpectedError < StandardError; end
  class UnknownOperationError < StandardError; end
  class BadJSONError < StandardError; end
  class IncomingChequeProcessingFailedError < StandardError; end
  class IncomingOperationNotSupportError < StandardError; end
  class IncomingMissingTokenError < StandardError; end
  class IncomingExpiredTokenError < StandardError; end
  class WrongLoginOrPasswordError < StandardError; end
  class ValidationError < StandardError; end
  class UserBlockedError < StandardError; end
  class IncomingExistExternalIdError < StandardError; end
  class GroupCodeToTokenError < StandardError; end
  class NotSupportedGroupCodeError < StandardError; end
  class EmptyClientContactError < StandardError; end
  class EmptySellItemsError < StandardError; end
  class IncomingValidationError < StandardError; end
  class StateMissingUuidError < StandardError; end
  class StateNotFoundError < StandardError; end
  class BadRequestError < StandardError; end
  class UnsupportedMediaTypeError < StandardError; end
  class ErrorServerConfigurationError < StandardError; end
  class ZeroItemQuantityError < StandardError; end
  class BadPaymentError < StandardError; end
  class EmptyPaymentsError < StandardError; end
  class PaymentsTotalMismatchError < StandardError; end

  # Service-level error codes (v5 protocol, section 7.1 "Ошибки сервиса"),
  # keyed by the integer error.code returned in the service response.
  ERRORS = Hash[
      0 => BadJSONError,
      1 => IncomingChequeProcessingFailedError,
      10 => IncomingMissingTokenError,
      11 => IncomingExpiredTokenError,
      12 => WrongLoginOrPasswordError,
      13 => ValidationError,
      14 => UserBlockedError,
      20 => GroupCodeToTokenError,
      21 => NotSupportedGroupCodeError,
      30 => StateMissingUuidError,
      31 => IncomingOperationNotSupportError,
      32 => IncomingValidationError,
      33 => IncomingExistExternalIdError,
      34 => StateNotFoundError,
      40 => BadRequestError,
      41 => UnsupportedMediaTypeError,
      50 => ErrorServerConfigurationError,
      -3804 => ZeroItemQuantityError
  ].freeze
end
