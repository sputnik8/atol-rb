require 'atol/errors'

module Atol
  module Request
    class PostDocument
      module Item
        class Body
          BadPaymentMethodError = Class.new(StandardError)
          BadPaymentObjectError = Class.new(StandardError)

          PAYMENT_METHODS = [
            'full_prepayment', 'prepayment', 'advance', 'full_payment',
            'partial_payment', 'credit', 'credit_payment'
          ]

          PAYMENT_OBJECTS = [
            'commodity', 'excise', 'job', 'service', 'gambling_bet', 'gambling_prize',
            'lottery', 'lottery_prize', 'intellectual_activity', 'payment', 'agent_commission',
            'composite', 'another'
          ]

          attr_accessor :config, :name, :price, :quantity, :payment_method, :payment_object

          def initialize(config: nil, name:, price:, quantity: 1, payment_method:, payment_object:)
            raise Atol::ZeroItemQuantityError if quantity.to_i.zero?
            raise BadPaymentMethodError unless PAYMENT_METHODS.include?(payment_method.to_s)
            raise BadPaymentObjectError unless PAYMENT_OBJECTS.include?(payment_object.to_s)

            self.config = config || Atol.config
            self.name = name
            self.price = price.to_f
            self.quantity = quantity.to_f
            self.payment_method = payment_method.to_s
            self.payment_object = payment_object.to_s
          end

          def to_h
            body.clone
          end

          def to_json
            body.to_json
          end

          private

          def body
            @body ||= {
              name: name,
              price: price,
              quantity: quantity,
              sum: (price * quantity).round(2),
              tax: config.default_tax,
              payment_method: payment_method,
              payment_object: payment_object
            }
          end
        end
      end
    end
  end
end
