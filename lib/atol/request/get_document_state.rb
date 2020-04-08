# frozen_string_literal: true

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
        @token = token
        @uuid = uuid
      end

      def call
        http_client = @config.http_client
        uri = URI("#{@config.api_url}/#{@config.group_code}/report/#{@uuid}")
        http = http_client.new(uri.host, uri.port)
        http.use_ssl = true
        http.get(uri.request_uri, 'Token' => @token)
      end
    end
  end
end
