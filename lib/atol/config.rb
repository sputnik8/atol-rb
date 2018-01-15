require 'anyway'

module Atol
  class Config < Anyway::Config
    attr_config :login, :password, :inn, :group_code,
                :payment_address, :default_sno, :default_tax
  end
end
