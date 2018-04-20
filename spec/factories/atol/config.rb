require './lib/atol/config'

module Atol
  class Config::Factory
    def self.example
      Atol::Config.new(overrides: {
        login: :example_login,
        password: :example_password,
        inn: :example_inn,
        group_code: :example_group_code,
        payment_address: :example_payment_address,
        default_sno: :example_default_sno,
        default_tax: :example_default_tax,
        http_client: Net::HTTP
      })
    end
  end
end
