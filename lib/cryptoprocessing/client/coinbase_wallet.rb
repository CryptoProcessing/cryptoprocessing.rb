module Cryptoprocessing
  class Client
    ##
    # Mimic Coinbase Wallet Client
    #
    module CoinbaseWallet
      ##
      #
      #
      def primary_account

      end

      # ##
      # #
      # #
      # def create_address(options)
      #   @client.create_address(options)
      # end

      ##
      #
      #
      def address_transactions(account_uid, address_uid, params = {})
        list_transactions = []

        @client.address_transactions(account_uid, address_uid) do |data, resp|
          data.each do |tx|
            if tx['confirmations_count'] > 3 && tx['type'] == 'send'
              list_transactions.append(tx)
            end
          end
        end
        list_transactions
      end

      ##
      #
      #
      def accounts
        []
      end
    end
  end
end