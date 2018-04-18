require 'cryptoprocessing/models/api_object'

module Cryptoprocessing
  class Address < APIObject
    def transactions(options = {})
      agent.transactions_by_address(self['account_id'], self['address'], options) do |data, resp|
        yield(data, resp) if block_given?
      end
    end

    def create_transaction(to_address, amount, options = {})
      agent.create_transaction(self['account_id'], self['address'], to_address, amount, options) do |data, resp|
        yield(data, resp) if block_given?
      end
    end
  end
end