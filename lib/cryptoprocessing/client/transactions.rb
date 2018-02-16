module Cryptoprocessing
  class Client
    # @see https://api.cryptoprocessing.io/#c42e8a72-9e11-c074-22ef-4fc9a70a1a8f
    module Transactions
      TRANSACTION_SEND_TYPE = 'send'
      TRANSACTION_SEND_TYPE_RAW = 'sendraw'

      TRANSACTION_FEE_FASTEST = 'fastestFee'
      TRANSACTION_FEE_HALF_HOUR = 'halfHourFee'
      TRANSACTION_FEE_HOUR = 'hourFee'

      # List transactions
      #
      # список транзакций
      #
      # @return [Array<Cryptoprocessing::Transaction>] A list of transactions
      # @see https://api.cryptoprocessing.io/#690f04ca-cc2b-750b-17c6-4cc290a65d98
      def transactions(account_id, options = {})
        currency = if options[:currency] then options[:currency] else blockchain_type end
        get "/v1/#{currency}/accounts/#{account_id}/transactions", options
      end

      # List transactions filtered by address
      #
      # @return [Array<Cryptoprocessing::Transaction>] A list of transactions
      # @see https://api.cryptoprocessing.io/#0e6e0dbc-1c1b-23db-dc54-a3b36ed276d8
      def transactions_by_address(account_id, address, options = {})
        currency = if options[:currency] then options[:currency] else blockchain_type end
        get "/v1/#{currency}/accounts/#{account_id}/transactions/address/#{address}", options
      end

      # Send raw transaction signed transaction to the blockchain
      #
      # Отсылаем в блокчейн сырую подписанную транзакцию
      #
      # @see https://api.cryptoprocessing.io/#655161a4-f6ff-6764-1667-8fb039912546
      def send_raw_transaction(raw_transaction_id, options = {})
        currency = if options[:currency] then options[:currency] else blockchain_type end
        options[:type] = TRANSACTION_SEND_TYPE_RAW
        options[:raw_transaction_id] = raw_transaction_id
        post "/v1/#{currency}/sendrawtx", options
      end

      # Create transaction
      #
      # Создаем транзакцию
      #
      # @see https://api.cryptoprocessing.io/#8dd94a75-4b09-588e-c9ad-c9cb5f165d72
      def create_transaction(account_id, options = {})
        currency = if options[:currency] then options[:currency] else blockchain_type end
        options[:type] = TRANSACTION_SEND_TYPE
        options[:fee] = TRANSACTION_FEE_FASTEST
        options[:from_] = options[:from]
        options[:to_] = options[:to]
        options.delete(:from)
        options.delete(:to)
        post "/v1/#{currency}/accounts/#{account_id}/transactions", options
      end
    end
  end
end