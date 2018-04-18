require 'cryptoprocessing/models/api_object'

module Cryptoprocessing
  class Account < APIObject
    # Create address
    def create_address(options = {})
      agent.create_address(self['id'], options) do |resp|
        yield(data, resp) if block_given?
      end
    end

    # List of transactions
    def transactions(options = {})
      agent.transactions(self['id'], options) do |data, resp|
        yield(data, resp) if block_given?
      end
    end

    # List of transactions by address
    def transactions_by_address(address, options = {})
      agent.transactions_by_address(self['id'], address, options) do |data, resp|
        yield(data, resp) if block_given?
      end
    end

    # Create transaction
    def create_transaction(options = {})
      agent.create_transaction(self['id'], options) do |data, resp|
        yield(data, resp) if block_given?
      end
    end

    def create_callback(address, options = {})
      agent.create_callback(self['id'], address, options) do |data, resp|
        yield(data, resp) if block_given?
      end
    end
  end
end