module Cryptoprocessing
  class Rails < ::Rails::Engine
    config.after_initialize do
      secrets = Rails.application.secrets
      if defined?(secrets.cryptoprocessing_api_endpoint)
        Cryptoprocessing.api_endpoint = secrets.cryptoprocessing_api_endpoint
      end
      if defined?(secrets.cryptoprocessing_api_namespace)
        Cryptoprocessing.api_namespace = secrets.cryptoprocessing_api_namespace
      end
    end
  end if defined?(::Rails)
end