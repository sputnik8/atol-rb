# frozen_string_literal: true

require 'atol/errors'

module Atol
  module Request
    class PostDocument
      module Item
        class Body
          BadPaymentMethodError = Class.new(StandardError)
          BadPaymentObjectError = Class.new(StandardError)
          BadAgentTypeError = Class.new(StandardError)

          PAYMENT_METHODS = [
            'full_prepayment', 'prepayment', 'advance', 'full_payment',
            'partial_payment', 'credit', 'credit_payment'
          ]

          PAYMENT_OBJECTS = [
            'commodity', 'excise', 'job', 'service', 'gambling_bet', 'gambling_prize',
            'lottery', 'lottery_prize', 'intellectual_activity', 'payment', 'agent_commission',
            'composite', 'another'
          ]

          AGENT_TYPES = [
            'bank_paying_agent', 'bank_paying_subagent', 'paying_agent',
            'paying_subagent', 'attorney', 'commission_agent', 'another'
          ]

          attr_accessor :config, :name, :price, :quantity, :payment_method,
                        :payment_object, :agent_type, :supplier_phones, :supplier_name,
                        :supplier_inn

          def initialize(
            config: nil, name:, price:, quantity: 1, payment_method:,
            payment_object:, agent_type: nil, supplier_phones: nil,
            supplier_name: nil, supplier_inn: nil
          )
            raise Atol::ZeroItemQuantityError if quantity.to_f.zero?
            raise BadPaymentMethodError unless PAYMENT_METHODS.include?(payment_method.to_s)
            raise BadPaymentObjectError unless PAYMENT_OBJECTS.include?(payment_object.to_s)
            raise BadAgentTypeError unless agent_type.nil? || AGENT_TYPES.include?(agent_type.to_s)

            self.config = config || Atol.config
            self.name = name
            self.price = price.to_f
            self.quantity = quantity.to_f
            self.payment_method = payment_method.to_s
            self.payment_object = payment_object.to_s
            self.agent_type = agent_type
            self.supplier_phones = supplier_phones.to_a
            self.supplier_name = supplier_name.to_s
            self.supplier_inn = supplier_inn.to_s
          end

          def to_h
            body.clone
          end

          def to_json(*_args)
            body.to_json
          end

          private

          def body
            @body ||= body_template.merge(optional_body_fields)
          end

          def body_template
            {
              name: name,
              price: price,
              quantity: quantity,
              sum: (price * quantity).round(2),
              tax: config.default_tax,
              payment_method: payment_method,
              payment_object: payment_object
            }
          end

          def optional_body_fields
            fields = {}
            if agent_type
              fields[:agent_info] = { type: agent_type }
              fields[:supplier_info] =
                {
                  phones: supplier_phones,
                  name: supplier_name,
                  inn: supplier_inn
                }
            end
            fields
          end
        end
      end
    end
  end
end
