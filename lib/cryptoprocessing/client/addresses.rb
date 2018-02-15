module Cryptoprocessing
  class Client

    # Methods for addresses
    #
    # @see https://api.cryptoprocessing.io/#be1b38bb-7702-51c6-192f-91cf3a506ae8
    module Addresses

      # Get address info
      #
      # @see https://api.cryptoprocessing.io/#55759d22-b04b-1a63-ca8d-6b881b0212b2
      def address(account_id, address, options = {})
        currency = if options[:currency] then options[:currency] else blockchain_type end
        get "/v1/#{currency}/accounts/#{account_id}/addresses/#{address}", options
      end

      # Get addresses list
      #
      # @return [Array<Cryptoprocessing::Address>] A list of addresses
      # @see https://api.cryptoprocessing.io/#b826594e-db0d-4efe-04e9-c1286e6f8948
      def addresses(account_id, options = {})
        currency = if options[:currency] then options[:currency] else blockchain_type end
        get "/v1/#{currency}/accounts/#{account_id}/addresses", options
      end

      # Create address for account
      #
      # @see https://api.cryptoprocessing.io/#d6486a95-a5cb-4d4b-0369-0c7af040bc4d
      def create_address(account_id, options = {})
        currency = if options[:currency] then options[:currency] else blockchain_type end
        post "/v1/#{currency}/accounts/#{account_id}/addresses", options
      end
    end
  end
end