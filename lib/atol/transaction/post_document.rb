require 'atol/request/post_document'
require 'atol/errors'

module Atol
  module Transaction
    class PostDocument
      ERRORS = {
        1 => Atol::BadJSONError,
        2 => Atol::IncomingBadRequestError,
        3 => Atol::IncomingOperationNotSupportError,
        4 => Atol::IncomingMissingTokenError,
        5 => Atol::IncomingNotExistTokenError,
        6 => Atol::IncomingExpiredTokenError,
        10 => Atol::IncomingExistExternalIdError,
        22 => Atol::GroupCodeToTokenError,
        23 => Atol::IsNullExternalIdError
      }

      def initialize(operation:, token:, body:, config: nil)
        @config = config || Atol.config
        raise(Atol::ConfigExpectedError) unless @config.is_a?(Atol::Config)
        @params = Hash[operation: operation, token: token, body: body, config: config]
      end

      def call
        request = Atol::Request::PostDocument.new(params)
        response = request.call
        encoded_body = response.body.force_encoding(Atol::ENCODING)
        json = JSON.parse(encoded_body)

        if response.code == '200' && json['error'].nil?
          return json
        elsif !ERRORS[json['error']['code']].nil?
          raise(ERRORS[json['error']['code']], encoded_body)
        else
          raise(encoded_body)
        end
      end

      private

      attr_reader :params
    end
  end
end
