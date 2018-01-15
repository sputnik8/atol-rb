require './lib/atol/config'

describe Atol::Config do
  it { expect(Atol::Config).to be_a Class }

  describe 'contains main attributes' do
    let(:config) do
      Atol::Config.new(overrides: {
        login: :example_login,
        password: :example_password,
        inn: :example_inn,
        group_code: :example_group_code,
        payment_address: :example_payment_address,
        default_sno: :example_default_sno,
        default_tax: :example_default_tax
      })
    end

    it('#login') { expect(config.login).to eql :example_login }
    it('#password') { expect(config.password).to eql :example_password }
    it('#inn') { expect(config.inn).to eql :example_inn }
    it('#group_code') { expect(config.group_code).to eql :example_group_code }
    it('#payment_address') { expect(config.payment_address).to eql :example_payment_address }
    it('#default_sno') { expect(config.default_sno).to eql :example_default_sno }
    it('#default_tax') { expect(config.default_tax).to eql :example_default_tax }
  end

  describe 'contains optional attributes' do
    let(:config) { Atol::Config.new }

    it('#req_tries_number') { expect(config.req_tries_number).to eql 3 }
  end
end
