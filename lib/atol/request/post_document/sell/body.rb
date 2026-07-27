# frozen_string_literal: true

require 'atol/errors'
require 'atol/request/post_document/payment'

module Atol
  module Request
    class PostDocument
      module Sell
        class Body
          def initialize(external_id:, phone: '', email: '', items:, payments: nil, config: nil, **options)
            raise(Atol::EmptyClientContactError) if phone.empty? && email.empty?
            raise(Atol::EmptySellItemsError) if items.empty?
            unless payments.nil?
              raise(Atol::EmptyPaymentsError) if payments.empty?
              raise(Atol::BadPaymentError) if payments.any? { |payment| !payment.is_a?(Payment) }
            end

            @config = config || Atol.config
            @external_id = external_id
            @phone = phone
            @email = email
            @items = items
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

          attr_reader :config, :external_id, :phone, :email, :items, :payments, :total

          def build_body
            {
              external_id: external_id,
              receipt: {
                client: client,
                company: company,
                items: items,
                payments: build_payments,
                total: total,
                internet: config.internet
              },
              service: service,
              timestamp: Time.now.strftime(Atol::TIMESTAMP_FORMAT)
            }
          end

          def client
            result = {}
            result[:email] = email unless email.empty?
            result[:phone] = phone unless phone.empty?

            result
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
        end
      end
    end
  end
end
