require 'cryptoprocessing/models/api_object'

module Cryptoprocessing
  class Account < APIObject
    def addresses(params = {})
      @client.addresses(self['id'], params) do |data, resp|
        yield(data, resp) if block_given?
      end
    end

    def create_address(params = {})
      @client.create_address(self['id'], params) do |data, resp|
        yield(data, resp) if block_given?
      end
    end

    def transactions

    end

    def transaction

    end
  end
end