require 'cryptoprocessing/models/transaction'

module Cryptoprocessing
  class Client
    # @see https://api.cryptoprocessing.io/#c42e8a72-9e11-c074-22ef-4fc9a70a1a8f
    module Transactions
      TRANSACTION_SEND_TYPE = 'send'
      TRANSACTION_SEND_TYPE_RAW = 'sendraw'

      TRANSACTION_FEE_FASTEST = 'fastestFee'
      TRANSACTION_FEE_HALF_HOUR = 'halfHourFee'
      TRANSACTION_FEE_HOUR = 'hourFee'

      # Get transaction
      #
      # Получить транзакцию
      #
      # @param [String] account_id
      # @param [String] txid
      # @return [Cryptoprocessing::Transaction] Transaction
      # @see https://api.cryptoprocessing.io/#9a0f12e1-1cae-4203-a89c-f033f5b66491
      def transaction(account_id, txid, options = {})
        out = nil
        currency = if options[:currency] then options[:currency] else blockchain_type end
        get("/v1/#{currency}/accounts/#{account_id}/transactions/#{txid}", options) do |resp|
          out = Cryptoprocessing::Transaction.new(self, resp.data)
          yield(out, resp) if block_given?
        end
        out
      end

      # List transactions
      #
      # список транзакций
      #
      # @param [String] account_id
      # @return [Array<Cryptoprocessing::Transaction>] A list of transactions
      # @see https://api.cryptoprocessing.io/#690f04ca-cc2b-750b-17c6-4cc290a65d98
      def transactions(account_id, options = {})
        out = nil
        currency = if options[:currency] then options[:currency] else blockchain_type end
        get("/v1/#{currency}/accounts/#{account_id}/transactions", options) do |resp|
          out = resp.data['transactions'].map { |item| Cryptoprocessing::Transaction.new(self, item) }
          yield(out, resp) if block_given?
        end
        out
      end

      # List transactions filtered by address
      #
      # @param [String] account_id
      # @param [String] address
      # @return [Array<Cryptoprocessing::Transaction>] A list of transactions
      # @see https://api.cryptoprocessing.io/#0e6e0dbc-1c1b-23db-dc54-a3b36ed276d8
      def transactions_by_address(account_id, address, options = {})
        out = nil
        currency = if options[:currency] then options[:currency] else blockchain_type end
        get("/v1/#{currency}/accounts/#{account_id}/transactions/address/#{address}", options) do |resp|
          out = resp.data.map { |item| Cryptoprocessing::Transaction.new(self, item) }
          yield(out, resp) if block_given?
        end
        out
      end

      # Send raw transaction signed transaction to the blockchain
      #
      # Отсылаем в блокчейн сырую подписанную транзакцию
      #
      # @param [String] raw_transaction_id
      # @return [Cryptoprocessing::Transaction]
      # @see https://api.cryptoprocessing.io/#655161a4-f6ff-6764-1667-8fb039912546
      def send_raw_transaction(raw_transaction_id, options = {})
        out = nil
        currency = if options[:currency] then options[:currency] else blockchain_type end
        options[:type] = TRANSACTION_SEND_TYPE_RAW
        options[:raw_transaction_id] = raw_transaction_id
        post("/v1/#{currency}/sendrawtx", options) do |resp|
          out = Cryptoprocessing::Transaction.new(self, resp.data.merge(options))
          yield(out, resp) if block_given?
        end
        out
      end

      # Create transaction
      #
      # Создаем транзакцию
      #
      # @param [String] account_id
      # @return [Cryptoprocessing::Transaction]
      # @see https://api.cryptoprocessing.io/#8dd94a75-4b09-588e-c9ad-c9cb5f165d72
      def create_transaction(account_id, options = {})
        out = nil
        currency = if options[:currency] then options[:currency] else blockchain_type end
        options[:type] = TRANSACTION_SEND_TYPE
        options[:fee] = options[:fee] || TRANSACTION_FEE_FASTEST
        options[:from_] = options[:from]
        options[:to_] = options[:to]
        options.delete(:from)
        options.delete(:to)
        post("/v1/#{currency}/accounts/#{account_id}/transactions", options) do |resp|
          out = Cryptoprocessing::Transaction.new(self, resp.data.merge(options))
          yield(out, resp) if block_given?
        end
        out
      end
    end
  end
end
