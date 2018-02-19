require 'cryptoprocessing/models/address'

module Cryptoprocessing
  class Client

    # Methods for addresses
    #
    # @return [Cryptoprocessing::Address]
    # @see https://api.cryptoprocessing.io/#be1b38bb-7702-51c6-192f-91cf3a506ae8
    module Addresses

      # Get address info
      #
      # @param [String] account_id
      # @param [String] address
      # @return [Cryptoprocessing::Address]
      # @see https://api.cryptoprocessing.io/#55759d22-b04b-1a63-ca8d-6b881b0212b2
      def address(account_id, address, options = {})
        out = nil
        currency = if options[:currency] then options[:currency] else blockchain_type end
        get("/v1/#{currency}/accounts/#{account_id}/addresses/#{address}", options) do |resp|
          out = Cryptoprocessing::Address.new(self, resp.data)
        end
        out
      end

      # Get addresses list
      #
      # @param [String] account_id
      # @return [Array<Cryptoprocessing::Address>] A list of addresses
      # @see https://api.cryptoprocessing.io/#b826594e-db0d-4efe-04e9-c1286e6f8948
      def addresses(account_id, options = {})
        out = nil
        currency = if options[:currency] then options[:currency] else blockchain_type end
        get("/v1/#{currency}/accounts/#{account_id}/addresses", options) do |resp|
          out = resp.data['addresses'].map { |item| Cryptoprocessing::Address.new(self, item) }
        end
        out
      end

      # Create address for account
      #
      # @param [String] account_id
      # @return [Cryptoprocessing::Address]
      # @see https://api.cryptoprocessing.io/#d6486a95-a5cb-4d4b-0369-0c7af040bc4d
      def create_address(account_id, options = {})
        out = nil
        currency = if options[:currency] then options[:currency] else blockchain_type end
        post("/v1/#{currency}/accounts/#{account_id}/addresses", options) do |resp|
          out = Cryptoprocessing::Address.new(self, resp.data)
        end
        out
      end
    end
  end
end