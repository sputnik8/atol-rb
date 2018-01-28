require 'anyway'

module Atol
  class Config < Anyway::Config
    DEFAULT_REQ_TRIES_NUMBER = 3
    DEFAULT_PAYMENT_TYPE = 1

    attr_config :login,
                :password,
                :inn,
                :group_code,
                :payment_address,
                :default_sno,
                :default_tax,
                req_tries_number: DEFAULT_REQ_TRIES_NUMBER,
                default_payment_type: DEFAULT_PAYMENT_TYPE
  end
end
