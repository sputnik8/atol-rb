require 'atol'
require 'atol/errors'
require 'net/http'

module Atol
  module Request
    class GetDocumentState
      def initialize(uuid:, token:, config: nil)
        @config = config || Atol.config
        raise(Atol::ConfigExpectedError) unless @config.is_a?(Atol::Config)
        raise(Atol::MissingConfigError, 'group_code missing') if @config.group_code.nil?

        @url = "#{Atol::URL}/#{@config.group_code}/report/#{uuid}?tokenid=#{token}"
        @http_client = @config.http_client
      end

      def call
        uri = URI(url)

        http = @http_client.new(uri.host, uri.port)
        http.use_ssl = true
        http.get(uri.request_uri)
      end

      private

      attr_reader :url
    end
  end
end
