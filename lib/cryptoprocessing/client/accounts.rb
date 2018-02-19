require 'cryptoprocessing/models/account'

module Cryptoprocessing
  class Client

    # Methods for the Commits API
    #
    # @see https://api.cryptoprocessing.io/#db40c5d3-078d-af2a-63e0-fd616f56e433
    module Accounts

      # Get account info
      #
      # @param [String] id
      # @return [Array<Cryptoprocessing::Account>] A list of accounts
      # @see https://api.cryptoprocessing.io/#4df50869-9044-21b6-bb27-a718f30e0040
      def account(id, options = {})
        currency = if options[:currency] then options[:currency] else blockchain_type end
        out = nil
        get("/v1/#{currency}/accounts/#{id}", options) do |resp|
          out = Cryptoprocessing::Account.new(self, resp.data['data'])
          yield(out, resp) if block_given?
        end
        out
      end

      # Create account for given currency and with given name
      #
      # Создаем аккаунт
      #
      # @return [Cryptoprocessing::Account]
      # @see https://api.cryptoprocessing.io/#7b3bacaf-aa8e-77ad-4d0d-f834b10ebc95
      def create_account(options = {})
        options[:currency] = blockchain_type unless options[:currency]
        out = nil
        post("/v1/accounts", options) do |resp|
          out = Cryptoprocessing::Account.new(self, resp.data.merge(options))
          yield(out, resp) if block_given?
        end
        out
      end
    end
  end
end