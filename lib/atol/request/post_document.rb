# frozen_string_literal: true

require 'atol'
require 'atol/errors'
require 'atol/request/post_document/item/body'
require 'atol/request/post_document/sell/body'

module Atol
  module Request
    class PostDocument
      OPERATIONS = %i[sell sell_refund sell_correction buy buy_refund buy_correction].freeze
      HEADERS = { 'Content-Type' => 'application/json; charset=utf-8' }.freeze

      def initialize(operation:, token:, body:, config: nil, req_logger: nil, res_logger: nil)
        @config = config || Atol.config

        raise(Atol::ConfigExpectedError) unless @config.is_a?(Atol::Config)
        raise(Atol::MissingConfigError, 'group_code missing') if @config.group_code.empty?
        raise(Atol::UnknownOperationError, operation.to_s) unless OPERATIONS.include?(operation.to_sym)

        @operation = operation
        @token = token
        @body = body
        @req_logger = req_logger
        @res_logger = res_logger
      end

      def call
        http_client = @config.http_client
        uri = URI("#{@config.api_url}/#{@config.group_code}/#{@operation}")
        req_headers = HEADERS.merge('Token' => @token)
        req = http_client::Post.new(uri, req_headers)
        req.body = @body

        @req_logger.call(req) if @req_logger.respond_to?(:call)

        res = http_client.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(req)
        end

        @res_logger.call(res) if @res_logger.respond_to?(:call)

        res
      end
    end
  end
end
