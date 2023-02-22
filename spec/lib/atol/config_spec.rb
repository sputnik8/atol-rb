# frozen_string_literal: true

require './lib/atol/config'

RSpec.describe Atol::Config do
  describe 'contains main attributes' do
    let(:config) do
      Atol::Config.new(overrides: {
        login: :example_login,
        password: :example_password,
        inn: :example_inn,
        group_code: :example_group_code,
        payment_address: :example_payment_address,
        default_sno: :example_default_sno,
        default_tax: :example_default_tax,
        http_client: :example_http_client,
        company_email: :example_company_email,
        api_url: 'example_api_url'
      })
    end

    it('#login') { expect(config.login).to eql :example_login }
    it('#password') { expect(config.password).to eql :example_password }
    it('#inn') { expect(config.inn).to eql :example_inn }
    it('#group_code') { expect(config.group_code).to eql :example_group_code }
    it('#payment_address') { expect(config.payment_address).to eql :example_payment_address }
    it('#default_sno') { expect(config.default_sno).to eql :example_default_sno }
    it('#default_tax') { expect(config.default_tax).to eql :example_default_tax }
    it('#http_client') { expect(config.http_client).to eql :example_http_client }
    it('#company_email') { expect(config.company_email).to eql :example_company_email }
    it('#api_url') { expect(config.api_url).to eql 'example_api_url' }
  end

  describe 'contains optional attributes' do
    let(:config) { Atol::Config.new }

    it('#req_tries_number') { expect(config.req_tries_number).to eql 3 }
    it('#default_payment_type') { expect(config.default_payment_type).to eql 1 }
    it('#api_url') { expect(config.api_url).to eql 'https://online.atol.ru/possystem/v4' }
    it('#http_client') { expect(config.http_client.name).to eql 'Net::HTTP' }

    it('#callback_url') do
      config.callback_url = 'url'
      expect(config.callback_url).to eql 'url'
    end
  end
end
