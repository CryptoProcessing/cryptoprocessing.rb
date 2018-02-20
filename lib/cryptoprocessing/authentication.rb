require 'cryptoprocessing/models/user'

module Cryptoprocessing

  # Authentication methods for {Cryptoprocessing::Client}
  #
  # Для аутентификации используется токен
  #
  # @see https://api.cryptoprocessing.io/#152a3087-a02e-de76-f156-2015c2ccefef
  module Authentication
    # Indicates if the client was supplied a bearer token
    #
    # @return [Boolean]
    def token_authenticated?
      !!@access_token
    end

    def login_from_netrc
      return unless netrc?

      require 'netrc'
      info = Netrc.read netrc_file
      netrc_host = URI.parse(api_endpoint).host
      creds = info[netrc_host]
      if creds.nil?
        # creds will be nil if there is no netrc for this end point
        puts "Error loading credentials from netrc file for #{api_endpoint}"
      else
        creds = creds.to_a
        self.login = creds.shift
        self.password = creds.shift
      end
    rescue LoadError
      puts "Please install netrc gem for .netrc support"
    end

    # Login user
    #
    # Логин пользователя
    #
    # @see https://api.cryptoprocessing.io/#e88a61dc-bb8f-e9cf-0e56-2729f200be9d
    def login(options)
      out = nil
      post('/auth/login', options) do |resp|
        @access_token = resp.body['auth_token']
        out = Cryptoprocessing::User.new self, resp.data
        yield(resp) if block_given?
      end
      out
    end

    # Register user
    #
    # Регистрация пользователя
    #
    # @see https://api.cryptoprocessing.io/#b0ec8c86-4c57-de45-5aea-e1cb6483e591
    def register(options)
      out = nil
      post('/auth/register', options) do |resp|
        @access_token = resp.body['auth_token']
        out = Cryptoprocessing::User.new self, resp.data
        yield(resp) if block_given?
      end
      out
    end
  end
end