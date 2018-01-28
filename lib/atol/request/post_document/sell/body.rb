require 'atol/errors'

module Atol
  module Request
    class PostDocument
      module Sell
        class Body
          def initialize(external_id:, phone: '', email: '', items:, config: nil)
            raise(Atol::EmptyClientContactError) if phone.empty? && email.empty?
            raise(Atol::EmptySellItemsError) if items.empty?
            @config = config || Atol.config

            @body = body_template
            @body[:external_id] = external_id
            @body[:receipt][:attributes][:email] = email unless email.empty?
            @body[:receipt][:attributes][:phone] = phone unless phone.empty?

            total = items.inject(0) do |sum, item|
              sum += item[:sum]
            end

            @body[:total] = @body[:payments][:sum] = total
            @body[:receipt][:items] = items
          end

          def to_h
            body.clone
          end

          def to_json
            body.to_json
          end

          private

          attr_reader :config, :body

          def body_template
            Hash[
              receipt: {
                attributes: {
                  sno: config.default_sno
                },
                items: []
              },
              payments: {
                sum: 0,
                type: config.default_payment_type
              },
              service: {
                inn: config.inn,
                payment_address: config.payment_address
              },
              timestamp: Time.now.strftime(Atol::TIMESTAMP_FORMAT),
              total: 0
            ]
          end
        end
      end
    end
  end
end