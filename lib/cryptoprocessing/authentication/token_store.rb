# Copyright 2018 OOM.AG.
#
#

module Cryptoprocessing
  module Api
    module Auth
      class TokenStore
        AUTHORIZATION_URI = 'https://accounts.google.com/o/oauth2/auth'
        TOKEN_CREDENTIAL_URI = 'https://accounts.google.com/o/oauth2/token'

        # @return [Object] Storage object.
        attr_accessor :store

        ##
        # Initializes the Storage object.
        #
        # @param [Object] store
        #  Storage object
        def initialize(store)
          @store = store
        end

        ##
        # Write the credentials to the specified store.
        #
        def write_credentials
          store.write_credentials(credentials_hash)
        end

        ##
        # refresh credentials and save them to store
        def refresh_authorization
          self.write_credentials
        end

        ##
        # Attempt to read in credentials from the specified store.
        def load_credentials
          store.load_credentials
        end

        ##
        # @return [Hash] with credentials
        def credentials_hash
          {
              :authorization_uri => AUTHORIZATION_URI,
              :token_credential_uri => TOKEN_CREDENTIAL_URI,
              :issued_at => authorization.issued_at.to_i,
              :auth_token => '',
              :user_id => '',
          }
        end
      end
    end
  end
end