require 'cryptoprocessing/models/callback'

module Cryptoprocessing
  class Client
    module Callbacks
      # Callback list
      #
      # @param [String] account_id
      # @return [Array<Cryptoprocessing::Callback>]
      # @see https://api.cryptoprocessing.io/#e8bbf0e7-38e7-3e98-17f5-04733f419242
      def callbacks(account_id, options = {})
        out = nil
        currency = if options[:currency] then options[:currency] else blockchain_type end
        get("/v1/#{currency}/accounts/#{account_id}/callback", options) do |resp|
          out = resp.data['addresses'].map { |item| Cryptoprocessing::Callback.new(self, item) }
          yield(out, resp) if block_given?
        end
        out
      end

      # Create callback
      #
      # @param [String] account_id
      # @param [String] address URL for callback
      # @return [Cryptoprocessing::Callback]
      # @see https://api.cryptoprocessing.io/#62b671c8-ba1c-5101-37a8-1ddf3dafb758
      def create_callback(account_id, address, options = {})
        out = nil
        currency = if options[:currency] then options[:currency] else blockchain_type end
        options[:address] = address
        post("/v1/#{currency}/accounts/#{account_id}/callback", options) do |resp|
          out = Cryptoprocessing::Callback.new(self, resp.body.merge(options))
          yield(out, resp) if block_given?
        end
        out
      end
    end
  end
end