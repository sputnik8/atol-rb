# frozen_string_literal: true

require 'atol/request/get_token'
require 'atol/errors'

module Atol
  module Transaction
    class GetToken
      def initialize(config: nil)
        @config = config || Atol.config
        raise(Atol::ConfigExpectedError) unless @config.is_a?(Atol::Config)
      end

      def call
        @config.req_tries_number.times do |i|
          request = Atol::Request::GetToken.new(config: @config)
          response = request.call
          encoded_body = response.body.dup.force_encoding(Atol::ENCODING)
          json = JSON.parse(encoded_body)

          case response.code
          when '200'
            return json['token']
          when '400'
            raise Atol::AuthBadRequestError
          when '401'
            raise Atol::AuthUserOrPasswordError
          when '500'
            next
          end
          raise "#{response.code} #{response.body}"
        end
      end
    end
  end
end