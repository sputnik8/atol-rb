require 'atol/errors'

module Atol
  module Request
    class PostDocument
      module Item
        class Body
          def initialize(name:, price:, quantity: 1, config: nil)
            raise Atol::ZeroItemQuantityError if quantity.to_i.zero?

            @config = config || Atol.config
            @name = name
            @price = price.to_f
            @quantity = quantity.to_f
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
              name: @name,
              price: @price,
              quantity: @quantity,
              sum: (@price * @quantity).round(2),
              tax: @config.default_tax
            }
          end
        end
      end
    end
  end
end
