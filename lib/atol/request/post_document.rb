require 'atol'
require 'atol/errors'
require 'net/http'

module Atol
  module Request
    class PostDocument
      OPERATIONS = %i[sell sell_refund sell_correction buy buy_refund buy_correction].freeze
      HEADERS = { 'Content-Type' => 'application/json' }.freeze

      def initialize(operation:, token:, body:, config: nil)
        @config = config || Atol.config
        raise(Atol::ConfigExpectedError) unless @config.is_a?(Atol::Config)
        raise(Atol::MissingConfigError, 'group_code missing') if @config.group_code.empty?

        unless OPERATIONS.include?(operation.to_sym)
          raise(Atol::UnknownOperationError, operation.to_s)
        end

        @url = "#{Atol::URL}"
        @url << '/'
        @url <<  @config.group_code
        @url << '/'
        @url <<  operation.to_s
        @url << '?token_id='
        @url << token

        @body = body
      end

      def call
        uri = URI(url)
        req = Net::HTTP::Post.new(uri, HEADERS)
        req.body = body

        Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(req)
        end
      end

      private

      attr_reader :url, :body
    end
  end
end
