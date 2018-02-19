require 'cryptoprocessing/authentication'
require 'cryptoprocessing/configurable'
require 'cryptoprocessing/connection'
require 'cryptoprocessing/client/accounts'
require 'cryptoprocessing/client/addresses'
require 'cryptoprocessing/client/callbacks'
require 'cryptoprocessing/client/trackers'
require 'cryptoprocessing/client/transactions'
require 'cryptoprocessing/client/coinbase_wallet'

module Cryptoprocessing

  # Cryptoprocessing API client masks default currency with BTC.
  # But default currency can be simply overridden with blockchain_type property.
  class Client
    include Cryptoprocessing::Authentication
    include Cryptoprocessing::Configurable
    include Cryptoprocessing::Connection
    include Cryptoprocessing::Client::Accounts
    include Cryptoprocessing::Client::Callbacks
    include Cryptoprocessing::Client::Addresses
    include Cryptoprocessing::Client::Trackers
    include Cryptoprocessing::Client::Transactions

    include Cryptoprocessing::Client::CoinbaseWallet

    attr_writer :logger

    def initialize(options = {})
      # Use options passed in, but fall back to module defaults
      Cryptoprocessing::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", options[key] || Cryptoprocessing.instance_variable_get(:"@#{key}"))
      end

      # login_from_netrc unless user_authenticated? || application_authenticated?
    end

    # Text representation of the client, masking tokens and passwords
    #
    # @return [String]
    def inspect
      inspected = super

      # mask password
      inspected = inspected.gsub! @password, "*******" if @password
      # Only show last 4 of token, secret
      if @access_token
        inspected = inspected.gsub! @access_token, "#{'*'*36}#{@access_token[36..-1]}"
      end

      inspected
    end

    # @!attribute [rw] logger
    # @return [Logger] The logger.
    def self.logger
      @logger ||= rails_logger || default_logger
    end

    # Create and configure a logger
    # @return [Logger]
    def self.default_logger
      logger = Logger.new($stdout)
      logger.level = Logger::WARN
      logger
    end

    # Check to see if client is being used in a Rails environment and get the logger if present.
    # Setting the ENV variable 'GOOGLE_API_USE_RAILS_LOGGER' to false will force the client
    # to use its own logger.
    #
    # @return [Logger]
    def self.rails_logger
      if 'true' == ENV.fetch('CRYPTOPROCESSING_USE_RAILS_LOGGER', 'true') &&
          defined?(::Rails) &&
          ::Rails.respond_to?(:logger) &&
          !::Rails.logger.nil?
        ::Rails.logger
      else
        nil
      end
    end

    # Set username for authentication
    #
    # @param value [String] Cryptoprocessing username
    def email=(value)
      reset_agent
      @email = value
    end

    # Set password for authentication
    #
    # @param value [String] Cryptoprocessing password
    def password=(value)
      reset_agent
      @password = value
    end

    # Set access token for authentication
    #
    # @param value [String] 40 character Cryptoprocessing access token
    def access_token=(value)
      reset_agent
      @access_token = value
    end
  end
end
