require 'uri'
require 'net/http'
require 'json/ext'
require 'cryptoprocessing/api/models/account'
require 'cryptoprocessing/api/models/address'
require 'cryptoprocessing/api/models/transaction'
require 'cryptoprocessing/api/models/user'

module Cryptoprocessing
  # Client for the Cryptoprocessing API
  #
  # @see https://api.cryptoprocessing.io
  class ApiClient
    def initialize(options = {})
      raise unless options.has_key? :access_token
      @access_token = options[:access_token]
      @api_uri = URI.parse(options[:api_url] || Cryptoprocessing::BASE_API_URL)
      @api_namespace = options[:api_namespace] || ''
      @blockchain_type = options[:blockchain_type] || Cryptoprocessing::DEFAULT_BLOCKCHAIN_TYPE

      @conn = Net::HTTP.new(@api_uri.host, @api_uri.port)
      @conn.use_ssl = true if @api_uri.scheme == 'https'
      # @conn.cert_store = self.class.whitelisted_certificates
      @conn.ssl_version = :TLSv1
    end

    


    ##
    # register
    #
    def register(params = {})
      [:email, :password].each do |param|
        raise Cryptoprocessing::APIError, "Missing parameter: #{param}" unless params.include? param
      end

      out = nil
      post("/auth/register", params) do |resp|
        out = Cryptoprocessing::User.new(self, resp.data)
        yield(out, resp) if block_given?
      end
      out
    end

    ##
    # login
    #
    def login(params = {})
      [:email, :password].each do |param|
        raise Cryptoprocessing::APIError, "Missing parameter: #{param}" unless params.include? param
      end

      out = nil
      post("/auth/login", params) do |resp|
        out = Cryptoprocessing::User.new(self, resp.data)
        yield(out, resp) if block_given?
      end
      out
    end


    ##
    # List Transactions
    #
    # @param [String] account_id
    def transactions(account_id, params = {})
      out = nil

      params['limit'] = params.limit || 50
      params['offset'] = params.offset || 1
      get("/v1/#{@blockchain_type}/accounts/#{account_id}/transactions") do |resp|
        out = resp.body['transactions'].map {|item| Cryptoprocessing::Transaction.new(self, item)}
        yield(out, resp) if block_given?
      end
      out
    end

    ##
    # List Transactions by address
    #
    # @param [String] account_id
    def address_transactions(account_id, address_id)
      out = nil
      get("/v1/#{@blockchain_type}/accounts/#{account_id}/transactions/address/#{address_id}") do |resp|
        out = resp.data.map {|item| Cryptoprocessing::Transaction.new(self, item)}
        yield(out, resp) if block_given?
      end
      out
    end

    ##
    # Send raw transaction
    #
    # @param [String] account_id
    def send_raw(account_id, params = {})
      [:type, :raw_transaction_id, :description].each do |param|
        raise Cryptoprocessing::APIError, "Missing parameter: #{param}" unless params.include? param
      end

      params['type'] = TRANSACTION_METHOD_TYPE_SEND_RAW
      params['raw_transaction_id'] = params['transaction_id']

      out = nil
      post("/v1/#{@blockchain_type}/accounts/#{account_id}/transactions", params) do |resp|
        out = Cryptoprocessing::Transaction.new(self, resp.data)
        yield(out, resp) if block_given?
      end
      out
    end

    ##
    # Create transaction
    #
    # @param [String] account_id
    def create_transaction(account_id, params = {})
      [:from_, :fee, :to_].each do |param|
        raise Cryptoprocessing::APIError, "Missing parameter: #{param}" unless params.include? param
      end

      params['type'] = TRANSACTION_METHOD_TYPE_SEND
      # Can be "fastestFee", "halfHourFee", "hourFee"
      params['fee'] = TRANSACTION_FEE_FASTEST

      # params['from_'] = ['sendraw']
      # params['description'] = 'another'
      # params['to_'] = ['some']

      out = nil
      post("/v1/#{@blockchain_type}/accounts/#{account_id}/transactions", params) do |resp|
        out = Cryptoprocessing::Transaction.new(self, resp.data)
        yield(out, resp) if block_given?
      end
      out
    end


    ##
    # Get account info
    #
    # @param [String] account_id
    def account(account_id, params = {})
      out = nil
      get("/v1/accounts/#{@blockchain_type}/accounts/#{account_id}", params) do |resp|
        out = Cryptoprocessing::Account.new(self, resp.data)
        yield(out, resp) if block_given?
      end
      out
    end

    ##
    # Create account
    #
    def create_account(params = {})
      [:currency, :name].each do |param|
        raise Cryptoprocessing::APIError, "Missing parameter: #{param}" unless params.include? param
      end

      out = nil
      post("/v1/accounts", params) do |resp|
        out = Cryptoprocessing::Account.new(self, resp.data)
        yield(out, resp) if block_given?
      end
      out
    end


    ##
    # List addresses
    #
    # @param [String] account_id
    def addresses(account_id, params = {})
      out = nil

      params['limit'] = params.limit || 50
      params['offset'] = params.offset || 1
      get("/v1/#{@blockchain_type}/accounts/#{account_id}/addresses", params) do |resp|
        out = resp.data.map {|item| Cryptoprocessing::Address.new(self, item)}
        yield(out, resp) if block_given?
      end
      out
    end

    ##
    # Show address
    #
    # @param [String] account_id
    # @param [String] address_id
    def address(account_id, address_id, params = {})
      out = nil
      get("/v1/#{@blockchain_type}/accounts/#{account_id}/addresses/#{address_id}", params) do |resp|
        out = Cryptoprocessing::Address.new(self, resp.data)
        yield(out, resp) if block_given?
      end
      out
    end

    ##
    # Add address
    #
    # @param [String] account_id
    def create_address(account_id, params = {})
      out = nil

      [:name].each do |param|
        raise Cryptoprocessing::APIError, "Missing parameter: #{param}" unless params.include? param
      end

      post("/v1/#{@blockchain_type}/accounts/#{account_id}/addresses", params) do |resp|
        out = Cryptoprocessing::Address.new(self, resp.data)
        yield(out, resp) if block_given?
      end
      out
    end
  end
end