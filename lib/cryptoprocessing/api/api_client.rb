require 'uri'
require 'net/http'
require 'json/ext'
require 'cryptoprocessing/api/models/account'
require 'cryptoprocessing/api/models/address'
require 'cryptoprocessing/api/models/transaction'
require 'cryptoprocessing/api/models/user'

module Cryptoprocessing
  class APIClient
    def initialize(options = {})
      raise unless options.has_key? :access_token
      @access_token = options[:access_token]
      @api_uri = URI.parse(options[:api_url] || Cryptoprocessing::BASE_API_URL)
      @blockchain_type = options[:blockchain_type] || Cryptoprocessing::DEFAULT_BLOCKCHAIN_TYPE

      @conn = Net::HTTP.new(@api_uri.host, @api_uri.port)
      @conn.use_ssl = true if @api_uri.scheme == 'https'
      # @conn.cert_store = self.class.whitelisted_certificates
      @conn.ssl_version = :TLSv1
    end

    def http_verb(method, path, body = nil, headers = {})
      case method
        when 'GET' then
          req = Net::HTTP::Get.new(path)
        when 'PUT' then
          req = Net::HTTP::Put.new(path)
        when 'POST' then
          req = Net::HTTP::Post.new(path)
        when 'DELETE' then
          req = Net::HTTP::Delete.new(path)
        else
          raise
      end

      req.body = body

      req['Content-Type'] = 'application/json'
      req['User-Agent'] = "cryproprocessing/ruby/#{Cryptoprocessing::Api::Client::VERSION}"
      auth_headers(method, path, body).each do |key, val|
        req[key] = val
      end
      headers.each do |key, val|
        req[key] = val
      end

      resp = @conn.request(req)
      out = NetHTTPResponse.new(resp)
      Cryptoprocessing::check_response_status(out)
      yield(out)
      out.data
    end

    def auth_headers(method, path, body)
      {:Authorization => "Bearer #{@access_token}"}
    end


    #
    # HTTP GET method
    #
    def get(path, params = {})
      uri = path
      if params.count > 0
        uri += "?#{URI.encode_www_form(params)}"
      end

      headers = {}

      http_verb('GET', uri, nil, headers) do |resp|
        if params[:fetch_all] == true &&
            resp.body.has_key?('pagination') &&
            resp.body['pagination']['next_uri'] != nil
          params[:starting_after] = resp.body['data'].last['id']
          get(path, params) do |page|
            body = resp.body
            body['data'] += page.data
            resp.body = body
            yield(resp)
          end
        else
          yield(resp)
        end
      end
    end

    #
    # HTTP PUT method
    #
    def put(path, params)
      headers = {}

      http_verb('PUT', path, params.to_json, headers) do |resp|
        yield(resp)
      end
    end

    #
    # HTTP POST method
    #
    def post(path, params)
      headers = {}

      http_verb('POST', path, params.to_json, headers) do |resp|
        yield(resp)
      end
    end

    #
    # HTTP DELETE method
    #
    def delete(path, params)
      headers = {}

      http_verb('DELETE', path, nil, headers) do |resp|
        yield(resp)
      end
    end


    #
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

    #
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


    #
    # List Transactions
    #
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

    #
    # List Transactions by address
    #
    def address_transactions(account_id, address_id)
      out = nil
      get("/v1/#{@blockchain_type}/accounts/#{account_id}/transactions/address/#{address_id}") do |resp|
        out = resp.data.map {|item| Cryptoprocessing::Transaction.new(self, item)}
        yield(out, resp) if block_given?
      end
      out
    end

    #
    # Send raw transaction
    #
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

    #
    # Create transaction
    #
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
        out =Cryptoprocessing:: Transaction.new(self, resp.data)
        yield(out, resp) if block_given?
      end
      out
    end


    #
    # Get account info
    #
    def account(account_id, params = {})
      out = nil
      get("/v1/accounts/#{@blockchain_type}/accounts/#{account_id}", params) do |resp|
        out = Cryptoprocessing::Account.new(self, resp.data)
        yield(out, resp) if block_given?
      end
      out
    end

    #
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


    #
    # List addresses
    #
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

    #
    # Show address
    #
    def address(account_id, address_id, params = {})
      out = nil
      get("/v1/#{@blockchain_type}/accounts/#{account_id}/addresses/#{address_id}", params) do |resp|
        out = Cryptoprocessing::Address.new(self, resp.data)
        yield(out, resp) if block_given?
      end
      out
    end

    #
    # Add address
    #
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