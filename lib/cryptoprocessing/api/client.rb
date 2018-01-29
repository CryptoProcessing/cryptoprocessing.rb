require 'cryptoprocessing/api/client/version'
require 'cryptoprocessing/api/api_response'
require 'cryptoprocessing/api/api_errors'

module Cryptoprocessing
  BASE_API_URL = 'https://api.cryptoprocessing.io'
  DEFAULT_BLOCKCHAIN_TYPE = 'btc'

  TRANSACTION_METHOD_TYPE_SEND = 'send'
  TRANSACTION_METHOD_TYPE_SEND_RAW = 'sendraw'

  TRANSACTION_FEE_FASTEST = 'fastestFee'
  TRANSACTION_FEE_HALF_HOUR = 'halfHourFee'
  TRANSACTION_FEE_HOUR = 'hourFee'

  # Net-Http response object
  class NetHTTPResponse < APIResponse
    def body
      JSON.parse(@response.body) rescue {}
    end

    def body=(body)
      @response.body = body.to_json
    end

    def data
      body
    end

    def headers
      out = @response.to_hash.map do |key, val|
        [key.upcase.gsub('_', '-'), val.count == 1 ? val.first : val]
      end
      out.to_h
    end

    def status
      @response.code.to_i
    end
  end

  def self.check_response_status(resp)
    (resp.body['warnings'] || []).each do |warning|
      message = "WARNING: #{warning['message']}"
      message += " (#{warning['url']})" if warning["url"]
      $stderr.puts message
    end

    # OAuth2 errors
    if resp.status >= 400 && resp.body['error']
      raise Cryptoprocessing::APIError, resp.body['error_description']
    end

    # Regular errors
    if resp.body['errors']
      case resp.status
        when 400
          case resp.body['errors'].first['id']
            when 'param_required' then
              raise ParamRequiredError, format_error(resp)
            when 'invalid_request' then
              raise InvalidRequestError, format_error(resp)
            when 'personal_details_required' then
              raise PersonalDetailsRequiredError, format_error(resp)
          end
          raise BadRequestError, format_error(resp)
        when 401
          case resp.body['errors'].first['id']
            when 'authentication_error' then
              raise AuthenticationError, format_error(resp)
            when 'unverified_email' then
              raise UnverifiedEmailError, format_error(resp)
            when 'invalid_token' then
              raise InvalidTokenError, format_error(resp)
            when 'revoked_token' then
              raise RevokedTokenError, format_error(resp)
            when 'expired_token' then
              raise ExpiredTokenError, format_error(resp)
          end
          raise AuthenticationError, format_error(resp)
        when 402 then
          raise TwoFactorRequiredError, format_error(resp)
        when 403 then
          raise InvalidScopeError, format_error(resp)
        when 404 then
          raise NotFoundError, format_error(resp)
        when 422 then
          raise ValidationError, format_error(resp)
        when 429 then
          raise RateLimitError, format_error(resp)
        when 500 then
          raise InternalServerError, format_error(resp)
        when 503 then
          raise ServiceUnavailableError, format_error(resp)
      end
    end

    if resp.status > 400
      raise APIError, "[#{resp.status}] #{resp.body}"
    end
  end

  class Client
    def initialize
      secrets = Rails.application.secrets
      @client = Cryptoprocessing::APIClient.new({
                                  api_url: secrets.cryptoprocessing_api_url,
                                  access_token: secrets.cryptoprocessing_token
                              })
    end

    def get_new_address(label)
      address = @client.create_address('some', {name: label})
      {account_uid: account.id, address: address}
    end

    def get_list_transactions(account_uid, address_uid, state = 'completed')
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

    def get_balance_for_address(account_uid, address_uid, state, from_timestamp = nil, to_timestamp = nil, currency = DEFAULT_BLOCKCHAIN_TYPE)
      balance = BigDecimal.new('0')

      @client.address_transactions(account_uid, address_uid) do |data, resp|
        data.each do |tx|
          if tx['confirmations_count'] > 3 && tx['type'] == 'send'
            if tx['currency'].downcase == currency
              if from_timestamp || to_timestamp
                created_at_timestamp = tx['created_at'].to_time.to_i
                next if from_timestamp && created_at_timestamp < from_timestamp
                next if to_timestamp && created_at_timestamp > to_timestamp
              end
              tx['receiver_addresses'].each do |addr|
                balance += addr['amount'].to_d
              end
            end
          end
        end
      end

      balance.to_d
    end

    def get_balance_for_address_in_usd(account_uid, address_uid, state, from_timestamp = nil, to_timestamp = nil)
      get_balance_for_address(account_uid, address_uid, state, from_timestamp, to_timestamp, 'usd')
    end

    def get_balance_for_address_in_eth(account_uid, address_uid, state, from_timestamp = nil, to_timestamp = nil)
      cryptocompare_client = CryptocompareClient.new
      balance = BigDecimal.new('0')

      @client.address_transactions(account_uid, address_uid) do |data, resp|
        data.each do |tx|
          if tx['status'] == state && (tx['type'] == 'send' || tx['type'] == 'order')
            if tx['currency'].downcase == 'usd'
              if from_timestamp || to_timestamp
                created_at_timestamp = tx['created_at'].to_time.to_i
                next if from_timestamp && created_at_timestamp < from_timestamp
                next if to_timestamp && created_at_timestamp > to_timestamp
              end

              amount = BigDecimal.new('0')

              tx['receiver_addresses'].each do |addr|
                amount += addr['amount'].to_d
              end

              tx_usd_per_btc = amount
              tx_timestamp = tx['created_at'].to_time.to_i

              tx_usd_per_eth = cryptocompare_client.get_cached_ratio_from_cryptocompare('ETH', 'USD', tx_timestamp)

              tx_eth_per_btc = tx_usd_per_btc.to_f / tx_usd_per_eth.to_f

              balance += tx_eth_per_btc
            end
          end
        end
      end

      balance.to_d
    end


    #
    # Coinbase naming only for compatibility
    #
    def get_coinbase_balance
      balance = BigDecimal.new('0')
      balance.to_d
    end

    def get_input_coinbase_balance_in_btc
      balance = BigDecimal.new('0')
      balance.to_d
    end


    def send_bitcoin(recipient_address, amount_btc, fee)
      params = {
          from_: ['some'],
          to_: [{address: recipient_address, amount: amount_btc}],
          fee: fee
      }
      @client.create_transaction('some', params)
    end

    def get_transaction_info(transaction_id)
      @client.address_transactions('some', transaction_id)
    end
  end
end
