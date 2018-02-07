require 'atol/errors'

module Atol
  module Request
    class PostDocument
      module Item
        class Body
          def initialize(name:, price:, quantity: 1, config: nil)
            @config = config || Atol.config

            raise Atol::ZeroItemQuantityError if quantity.to_i.zero?

            @body = Hash[]
            @body[:name] = name
            @body[:price] = price.to_f
            @body[:quantity] = quantity.to_f
            @body[:sum] = @body[:price] * @body[:quantity]
            @body[:tax] = @config.default_tax
          end

          def to_h
            body.clone
          end

          private

          attr_reader :body
        end
      end
    end
  end
end