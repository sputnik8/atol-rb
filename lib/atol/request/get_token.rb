require 'atol'
require 'atol/errors'
require 'net/http'

module Atol
  module Request
    class GetToken
      PATH = '/getToken'.freeze

      def initialize(context = {})
        config = context[:config] || Atol.config

        if config.login.nil? || config.login.empty?
          raise(Atol::MissingConfigError, 'login missing')
        else
          @login = config.login
        end

        if config.password.nil? || config.login.empty?
          raise(Atol::MissingConfigError, 'password missing')
        else
          @password = config.password
        end
      end

      def call
        uri = URI(Atol::URL + PATH)
        uri.query = URI.encode_www_form(login: login, pass: password)

        Net::HTTP.get_response(uri)
      end

      private

      attr_reader :login, :password
    end
  end
end
