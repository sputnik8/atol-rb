require 'atol'
require 'atol/errors'
require 'net/http'

module Atol
  module Request
    class GetToken
      PATH = '/getToken'.freeze

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
      end

      def call
        uri = URI(Atol::URL + PATH)
        uri.query = URI.encode_www_form(login: login, pass: password)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.get(uri.request_uri)
      end

      private

      attr_reader :login, :password
    end
  end
end
