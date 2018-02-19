require 'cryptoprocessing/models/api_object'

module Cryptoprocessing
  class Account < APIObject
    def addresses(params = {})
      agent.addresses(self['id'], params) do |data, resp|
        yield(data, resp) if block_given?
      end
    end

    def create_address(params = {})
      agent.create_address(self['id'], params) do |data, resp|
        yield(data, resp) if block_given?
      end
    end

    def transactions
      agent.transactions_by_address(self['id'], params) do |data, resp|
        yield(data, resp) if block_given?
      end
    end

    def transaction

    end
  end
end