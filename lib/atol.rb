require 'atol/version'
require 'atol/config'
require 'atol/request'
require 'atol/transaction'

module Atol
  URL = "https://online.atol.ru/possystem/#{Atol::Version::API}".freeze
  ENCODING = 'utf-8'.freeze
  TIMESTAMP_FORMAT = '%d.%m.%Y %H:%M:%S'.freeze

  class << self
    attr_writer :config

    def config
      @config ||= Atol::Config.new
    end
  end
end

