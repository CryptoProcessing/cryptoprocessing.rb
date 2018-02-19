require 'cryptoprocessing/models/tracker'

module Cryptoprocessing
  class Client
    module Trackers
      # Tracking address list
      #
      # @param [String] account_id
      # @see https://api.cryptoprocessing.io/#bb7723d0-761b-46cd-f6ed-9ca2699f47df
      def trackers(account_id, options = {})
        out = nil
        currency = if options[:currency] then options[:currency] else blockchain_type end
        get("/v1/#{currency}/accounts/#{account_id}/tracing/address", options) do |resp|
          out = resp.data['addresses'].map { |item| Cryptoprocessing::Tracker.new(self, item) }
          yield(out, resp) if block_given?
        end
        out
      end

      # Add address for tracking
      #
      # @param [String] account_id
      # @param [String] address
      # @see https://api.cryptoprocessing.io/#bb7723d0-761b-46cd-f6ed-9ca2699f47df
      def create_tracker(account_id, address, options = {})
        out = nil
        currency = if options[:currency] then options[:currency] else blockchain_type end
        options[:address] = address
        post("/v1/#{currency}/accounts/#{account_id}/tracing/address", options) do |resp|
          out = Cryptoprocessing::Tracker.new(self, resp.data.merge(options))
          yield(out, resp) if block_given?
        end
        out
      end
    end
  end
end