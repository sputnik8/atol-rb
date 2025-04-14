# frozen_string_literal: true

require 'atol/request/post_document'
require 'atol/errors'

module Atol
  module Transaction
    class PostDocument
      def initialize(operation:, token:, body:, config: nil, req_logger: nil, res_logger: nil)
        @config = config || Atol.config
        raise(Atol::ConfigExpectedError) unless @config.is_a?(Atol::Config)

        @params = {
          operation: operation,
          token: token,
          body: body,
          config: config,
          req_logger: req_logger,
          res_logger: res_logger
        }
      end

      def call
        request = Atol::Request::PostDocument.new(**@params)
        response = request.call
        encoded_body = response.body.dup.force_encoding(Atol::ENCODING)
        json = JSON.parse(encoded_body)

        if response.code == '200' && json['error'].nil?
          json
        elsif ERRORS[json['error']['code']]
          raise(ERRORS[json['error']['code']], encoded_body)
        else
          raise(encoded_body)
        end
      end
    end
  end
end
