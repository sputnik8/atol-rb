require 'atol/version'
require 'atol/config'

module Atol
  URL = "https://online.atol.ru/possystem/#{Atol::Version::API}".freeze
  ENCODING = 'utf-8'.freeze

  class << self
    attr_writer :config

    def config
      @config ||= Atol::Config.new
    end
  end
end
