# frozen_string_literal: true

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

          attr_accessor :config, :name, :price, :quantity, :payment_method, :payment_object,
                        :agent_info_type, :supplier_info_inn, :supplier_info_name

          def initialize(config: nil, name:, price:, quantity: 1, payment_method:, payment_object:, **options)
            setup_attributes(config, name, price, quantity, payment_method, payment_object, options)
            validate_attributes
          end

          def to_h
            body.clone
          end

          def to_json(*_args)
            body.to_json
          end

          private

          def setup_attributes(config, name, price, quantity, payment_method, payment_object, options)
            self.config = config || Atol.config
            self.name = name
            self.price = price.to_f
            self.quantity = quantity.to_f
            self.payment_method = payment_method.to_s
            self.payment_object = payment_object.to_s
            self.agent_info_type = options[:agent_info_type].to_s
            self.supplier_info_inn = options[:supplier_info_inn].to_s
            self.supplier_info_name = options[:supplier_info_name].to_s
          end

          def validate_attributes
            raise Atol::ZeroItemQuantityError if quantity.to_f.zero?
            raise BadPaymentMethodError unless PAYMENT_METHODS.include?(payment_method)
            raise BadPaymentObjectError unless PAYMENT_OBJECTS.include?(payment_object)
          end

          def agent_info
            return if agent_info_type.nil? || agent_info_type.empty?

            { agent_info: { type: agent_info_type } }
          end

          def supplier_info
            return if supplier_info_inn.nil? || supplier_info_inn.empty? || agent_info.nil?

            info = { inn: supplier_info_inn, name: supplier_info_name }
            filtered_info = info.reject { |_key, value| value&.empty? }
            { supplier_info: filtered_info } unless filtered_info.empty?
          end

          def body
            @body ||= {
              name: name,
              price: price,
              quantity: quantity,
              sum: (price * quantity).round(2),
              tax: config.default_tax,
              payment_method: payment_method,
              payment_object: payment_object
            }.merge(supplier_info.to_h, agent_info.to_h)
          end
        end
      end
    end
  end
end
