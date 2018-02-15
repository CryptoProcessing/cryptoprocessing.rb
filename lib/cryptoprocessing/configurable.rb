module Cryptoprocessing

  # Configuration options for {Client}, defaulting to values
  # in {Default}
  module Configurable
    # @!attribute [w] access_token
    #   @return [String] Access token for authentication
    attr_accessor :access_token, :blockchain_type, :user_agent
    # @!attribute api_endpoint
    #   @return [String] Base URL for API requests.
    attr_writer :email, :password, :api_endpoint, :api_namespace

    class << self
      # List of configurable keys for {Cryptoprocessing::Client}
      # @return [Array] of option keys
      def keys
        @keys ||= [
            :access_token,
            :api_endpoint,
            :api_namespace,
            :blockchain_type,
            :email,
            :password,
            :user_agent
        ]
      end
    end

    # Set configuration options using a block
    def configure
      yield self
    end

    # Reset configuration options to default values
    def reset!
      Cryptoprocessing::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", Cryptoprocessing::Default.options[key])
      end
      self
    end
    alias setup reset!

    def blockchain_type
      @blockchain_type
    end

    def api_endpoint
      File.join(@api_endpoint, '')
    end

    def api_namespace
      File.join(@api_namespace, '')
    end

    def netrc?
      !!@netrc
    end

    private

    def options
      Hash[Cryptoprocessing::Configurable.keys.map{|key| [key, instance_variable_get(:"@#{key}")]}]
    end
  end
end