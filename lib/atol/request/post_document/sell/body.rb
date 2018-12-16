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

          def to_json
            body.to_json
          end

          private

          def body
            @body ||= body_template.tap do |result|
              result[:external_id] = @external_id
              result[:receipt][:client][:email] = @email unless @email.empty?
              result[:receipt][:client][:phone] = @phone unless @phone.empty?
              result[:service][:callback_url] = @config.callback_url if @config.callback_url

              total = @items.inject(0) { |sum, item| sum += item[:sum] }

              result[:receipt][:total] = total
              result[:receipt][:payments][0][:sum] = total
              result[:receipt][:items] = @items
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
        end
      end
    end
  end
end
