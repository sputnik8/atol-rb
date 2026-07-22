# frozen_string_literal: true

require 'atol/errors'
require 'atol/request/post_document/payment'

module Atol
  module Request
    class PostDocument
      module Correction
        class Body
          class BadCorrectionTypeError < StandardError; end
          class BadCorrectionBaseDateError < StandardError; end
          class BadCorrectionBaseNumberError < StandardError; end

          CORRECTION_TYPES = %w[self instruction].freeze
          BASE_DATE_FORMAT = /\A\d{2}\.\d{2}\.\d{4}\z/
          BASE_NUMBER_MAX_LENGTH = 32

          def initialize(external_id:, items:, correction_type:, base_date:,
                         payments: nil, base_number: nil, config: nil, **options)
            raise(Atol::EmptySellItemsError) if items.empty?
            raise(BadCorrectionTypeError) unless CORRECTION_TYPES.include?(correction_type)
            raise(BadCorrectionBaseDateError) unless base_date.to_s.match?(BASE_DATE_FORMAT)
            raise(BadCorrectionBaseNumberError) if base_number && base_number.to_s.length > BASE_NUMBER_MAX_LENGTH
            unless payments.nil?
              raise(Atol::EmptyPaymentsError) if payments.empty?
              raise(Atol::BadPaymentError) if payments.any? { |payment| !payment.is_a?(Payment) }
            end

            @config = config || Atol.config
            @external_id = external_id
            @items = items
            @correction_type = correction_type
            @base_date = base_date
            @base_number = base_number
            @total = items.sum { |item| item[:sum] }
            @payments = payments
          end

          def to_h
            build_body.clone
          end

          def to_json(*_args)
            build_body.to_json
          end

          private

          attr_reader :config, :external_id, :items, :payments, :correction_type, :base_date, :base_number, :total

          def build_body
            {
              external_id: external_id,
              correction: {
                company: company,
                correction_info: correction_info,
                items: items,
                payments: build_payments,
                total: total
              },
              service: service,
              timestamp: Time.now.strftime(Atol::TIMESTAMP_FORMAT)
            }
          end

          def company
            {
              inn: config.inn.to_s,
              sno: config.default_sno,
              payment_address: config.payment_address,
              email: config.company_email
            }
          end

          def build_payments
            (payments || [Payment.new(type: config.default_payment_type, sum: total)]).map(&:to_h)
          end

          def service
            config.callback_url ? { callback_url: config.callback_url } : {}
          end

          def correction_info
            info = { type: correction_type, base_date: base_date }
            info[:base_number] = base_number if base_number

            info
          end
        end
      end
    end
  end
end
