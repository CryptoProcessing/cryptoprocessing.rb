require 'cryptoprocessing/version'

module Cryptoprocessing
  module Default
    # Default API endpoint
    API_ENDPOINT = 'https://api.cryptoprocessing.io'.freeze

    # Default API namespace (suffix)
    API_NAMESPACE = '/api'.freeze

    BLOCKCHAIN_TYPE = 'btc'.freeze

    # Default User Agent header string
    USER_AGENT = "cryproprocessing/ruby/#{Cryptoprocessing::VERSION}".freeze

    class << self

      # Configuration options
      # @return [Hash]
      def options
        Hash[Cryptoprocessing::Configurable.keys.map{|key| [key, send(key)]}]
      end

      # Default access token from ENV
      # @return [String]
      def access_token
        ENV['CRYPTOPROCESSING_ACCESS_TOKEN']
      end

      # Default API endpoint from ENV or {API_ENDPOINT}
      # @return [String]
      def api_endpoint
        ENV['CRYPTOPROCESSING_API_ENDPOINT'] || API_ENDPOINT
      end

      # Default API namespace from ENV or {API_NAMESPACE}
      # @return [String]
      def api_namespace
        ENV['CRYPTOPROCESSING_API_NAMESPACE'] || API_NAMESPACE
      end

      def blockchain_type
        ENV['CRYPTOPROCESSING_BLOCKCHAIN_TYPE'] || BLOCKCHAIN_TYPE
      end

      # Default Cryptoprocessing email for Auth from ENV
      # @return [String]
      def email
        ENV['CRYPTOPROCESSING_EMAIL']
      end

      # Default Cryptoprocessing password for Auth from ENV
      # @return [String]
      def password
        ENV['CRYPTOPROCESSING_PASSWORD']
      end

      # Default User-Agent header string from ENV or {USER_AGENT}
      # @return [String]
      def user_agent
        ENV['CRYPTOPROCESSING_USER_AGENT'] || USER_AGENT
      end

      # Default behavior for reading .netrc file
      # @return [Boolean]
      def netrc
        ENV['CRYPTOPROCESSING_NETRC'] || false
      end

      # Default path for .netrc file
      # @return [String]
      def netrc_file
        ENV['CRYPTOPROCESSING_NETRC_FILE'] || File.join(ENV['HOME'].to_s, '.netrc')
      end
    end

  end
end