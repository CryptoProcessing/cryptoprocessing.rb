require 'cryptoprocessing/models/api_object'

module Cryptoprocessing
  class Address < APIObject
    def transactions(options = {})
      agent.get("#{self['resource_path']}/transactions", options) do |resp|
        out = resp.data.map { |item| Cryptoprocessing::Transaction.new(self, item) }
        yield(out, resp) if block_given?
      end
    end

    def transaction(options = {})
      agent.post("#{self['resource_path']}/transactions", options) do |resp|
        out = resp.data.map { |item| Cryptoprocessing::Transaction.new(self, item) }
        yield(out, resp) if block_given?
      end
    end
  end
end