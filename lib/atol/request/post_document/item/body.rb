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
            @price = price
            @quantity = quantity
          end

          def to_h
            body.clone
          end

          private

          def body
            @body ||= {}.tap do |result|
              result[:name] = @name
              result[:price] = @price.to_f
              result[:quantity] = @quantity.to_f
              result[:sum] = (result[:price] * result[:quantity]).to_f.round(2)
              result[:tax] = @config.default_tax
            end
          end
        end
      end
    end
  end
end
