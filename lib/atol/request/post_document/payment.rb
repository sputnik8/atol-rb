# frozen_string_literal: true

require 'atol/errors'

module Atol
  module Request
    class PostDocument
      class Payment
        CASH_TYPE = 0                   # наличные
        CASHLESS_TYPE = 1               # безналичный
        PREPAID_TYPE = 2                # предоплата/зачёт аванса (тег 1215)
        POSTPAID_TYPE = 3               # постоплата/кредит
        COUNTER_PROVISION_TYPE = 4      # встречное предоставление
        EXTENDED_5_TYPE = 5             # расширенный тип оплаты 5
        EXTENDED_6_TYPE = 6             # расширенный тип оплаты 6
        EXTENDED_7_TYPE = 7             # расширенный тип оплаты 7
        EXTENDED_8_TYPE = 8             # расширенный тип оплаты 8
        EXTENDED_9_TYPE = 9             # расширенный тип оплаты 9

        TYPES = [
          CASH_TYPE, CASHLESS_TYPE, PREPAID_TYPE, POSTPAID_TYPE, COUNTER_PROVISION_TYPE,
          EXTENDED_5_TYPE, EXTENDED_6_TYPE, EXTENDED_7_TYPE, EXTENDED_8_TYPE, EXTENDED_9_TYPE
        ].freeze

        attr_reader :type, :sum

        def initialize(type:, sum:)
          @type = type
          @sum = sum
          validate!
        end

        def to_h
          { sum: sum, type: type }
        end

        private

        def validate!
          raise(Atol::BadPaymentError) unless valid?
        end

        def valid?
          TYPES.include?(type) && sum.is_a?(Numeric)
        end
      end
    end
  end
end
