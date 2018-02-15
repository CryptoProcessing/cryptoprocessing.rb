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
    def bearer_authenticated?
      !!@bearer_token
    end

    def login_from_netrc
      return unless netrc?

      require 'netrc'
      info = Netrc.read netrc_file
      netrc_host = URI.parse(api_endpoint).host
      creds = info[netrc_host]
      if creds.nil?
        # creds will be nil if there is no netrc for this end point
        octokit_warn "Error loading credentials from netrc file for #{api_endpoint}"
      else
        creds = creds.to_a
        self.login = creds.shift
        self.password = creds.shift
      end
    rescue LoadError
      octokit_warn "Please install netrc gem for .netrc support"
    end

    def login(options)
      post '/auth/login', options
    end

    def register(options)
      post '/auth/register', options
    end
  end
end