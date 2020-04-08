# frozen_string_literal: true

require 'atol/version'
require 'atol/config'
require 'atol/request'
require 'atol/transaction'

module Atol
  ENCODING = 'utf-8'
  TIMESTAMP_FORMAT = '%d.%m.%Y %H:%M:%S'

  class << self
    attr_writer :config

    def config
      @config ||= Atol::Config.new
    end
  end
end
