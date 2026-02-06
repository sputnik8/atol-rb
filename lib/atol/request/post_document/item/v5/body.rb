# frozen_string_literal: true

require 'atol/errors'

module Atol
  module Request
    class PostDocument
      module Item
        module V5
          class Body
            BadPaymentMethodError = Class.new(StandardError)
            BadPaymentObjectError = Class.new(StandardError)
            BadMeasureError = Class.new(StandardError)
            BadVatTypeError = Class.new(StandardError)

            # https://atol-kassa.ru/wp-content/nfiles/files/ATOL/kassa/АТОЛ%20Онлайн%20-%20Описание%20протокола%20v5%20(ФФД%201.2).pdf

            PAYMENT_METHODS = %w[full_prepayment prepayment advance full_payment partial_payment credit credit_payment].freeze
            PAYMENT_OBJECTS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23].freeze
            MEASURE = [0, 10, 11, 12, 20, 21, 22, 30, 31, 32, 40, 41, 42, 50, 51, 70, 71, 72, 73, 80, 81, 82, 83, 255].freeze
            VAT_TYPES = %w[none vat0 vat10 vat110 vat20 vat120].freeze

            attr_accessor :name,
                          :price,
                          :quantity,
                          :payment_method,
                          :payment_object,
                          :agent_info_type,
                          :supplier_info_inn,
                          :supplier_info_name,
                          :measure,
                          :vat

            def initialize(name:, price:, quantity: 1, payment_method:, payment_object:, **options)
              setup_attributes(name, price, quantity, payment_method, payment_object, options)
              validate_attributes
            end

            def to_h
              body.clone
            end

            def to_json(*_args)
              body.to_json
            end

            private

            def setup_attributes(name, price, quantity, payment_method, payment_object, options)
              self.name = name
              self.price = price.to_f
              self.quantity = quantity.to_f
              self.payment_method = payment_method.to_s
              self.payment_object = payment_object
              self.agent_info_type = options[:agent_info_type].to_s
              self.supplier_info_inn = options[:supplier_info_inn].to_s
              self.supplier_info_name = options[:supplier_info_name].to_s
              self.measure = options[:measure]
              self.vat = options[:vat]
            end

            def validate_attributes
              raise Atol::ZeroItemQuantityError if quantity.to_f.zero?
              raise BadPaymentMethodError unless PAYMENT_METHODS.include?(payment_method)
              raise BadPaymentObjectError unless PAYMENT_OBJECTS.include?(payment_object)
              raise BadMeasureError unless MEASURE.include?(measure)
              raise BadVatTypeError unless VAT_TYPES.include?(vat&.[](:type))
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
                payment_method: payment_method,
                payment_object: payment_object,
                measure: measure,
                vat: vat
              }.merge(supplier_info.to_h, agent_info.to_h)
            end
          end
        end
      end
    end
  end
end
