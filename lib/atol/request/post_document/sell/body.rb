# frozen_string_literal: true

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
            @external_id = external_id
            @phone = phone
            @email = email
            @items = items
          end

          def to_h
            body.clone
          end

          def to_json(*_args)
            body.to_json
          end

          private

          def body
            body_template.tap do |result|
              receipt = result[:receipt]
              client = receipt[:client]
              result[:external_id] = @external_id
              client[:email] = @email unless @email.empty?
              client[:phone] = @phone unless @phone.empty?
              result[:service][:callback_url] = @config.callback_url if @config.callback_url

              receipt[:total] = receipt[:payments][0][:sum] = total
              receipt[:items] = @items
            end
          end

          def body_template
            {
              receipt: {
                client: {},
                company: {
                  inn: @config.inn.to_s,
                  sno: @config.default_sno,
                  payment_address: @config.payment_address,
                  email: @config.company_email
                },
                items: [],
                payments: [
                  {
                    sum: 0,
                    type: @config.default_payment_type
                  }
                ]
              },
              service: {},
              timestamp: Time.now.strftime(Atol::TIMESTAMP_FORMAT)
            }
          end

          def total
            @total ||= @items.inject(0) { |sum, item| sum += item[:sum] }
          end
        end
      end
    end
  end
end
