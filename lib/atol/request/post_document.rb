require 'atol'
require 'atol/errors'
require 'net/http'
require 'atol/request/post_document/item/body'
require 'atol/request/post_document/sell/body'

module Atol
  module Request
    class PostDocument
      OPERATIONS = %i[sell sell_refund sell_correction buy buy_refund buy_correction].freeze
      HEADERS = { 'Content-Type' => 'application/json' }.freeze

      def initialize(operation:, token:, body:, config: nil, req_logger: nil, res_logger: nil)
        @config = config || Atol.config

        raise(Atol::ConfigExpectedError) unless @config.is_a?(Atol::Config)
        raise(Atol::MissingConfigError, 'group_code missing') if @config.group_code.empty?
        raise(Atol::UnknownOperationError, operation.to_s) unless OPERATIONS.include?(operation.to_sym)

        @url = "#{Atol::URL}/#{@config.group_code}/#{operation}?tokenid=#{token}"
        @body = body
        @req_logger = req_logger
        @res_logger = res_logger
      end

      def call
        uri = URI(url)
        req = Net::HTTP::Post.new(uri, HEADERS)
        req.body = body

        if req_logger.respond_to?(:call)
          req_logger.call(req)
        end

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(req)
        end

        if res_logger.respond_to?(:call)
          res_logger.call(res)
        end

        res
      end

      private

      attr_reader :url, :body, :req_logger, :res_logger
    end
  end
end
