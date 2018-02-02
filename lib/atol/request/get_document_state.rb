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
      end

      def call
        uri = URI(url)
        Net::HTTP.get_response(uri)
      end

      private

      attr_reader :url
    end
  end
end
