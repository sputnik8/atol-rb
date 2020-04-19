# frozen_string_literal: true

require 'atol'
require 'atol/errors'

module Atol
  module Request
    class GetToken
      PATH = '/getToken'

      def initialize(config: nil)
        @config = config || Atol.config
        raise(Atol::ConfigExpectedError) unless @config.is_a?(Atol::Config)

        if @config.login.nil? || @config.login.empty?
          raise(Atol::MissingConfigError, 'login missing')
        else
          @login = @config.login
        end

        if @config.password.nil? || @config.login.empty?
          raise(Atol::MissingConfigError, 'password missing')
        else
          @password = @config.password
        end

        @http_client = @config.http_client
      end

      def call
        uri = URI(@config.api_url + PATH)
        uri.query = URI.encode_www_form(login: @login, pass: @password)

        http = @http_client.new(uri.host, uri.port)
        http.use_ssl = true
        http.get(uri.request_uri)
      end
    end
  end
end
