# encoding: utf-8
# frozen_string_literal: true
require 'cryptoprocessing/client'
require 'cryptoprocessing/default'

# Ruby module for to access Cryptoprocessing API
module Cryptoprocessing
  class << self
    include Cryptoprocessing::Configurable

    # API client based on configured options {Configurable}
    #
    # @return [Cryptoprocessing::Client] API wrapper
    def client
      return @client if defined?(@client) && @client.same_options?(options)
      @client = Cryptoprocessing::Client.new(options)
    end

    private

    def respond_to_missing?(method_name, include_private=false)
      client.respond_to?(method_name, include_private)
    end

    def method_missing(method_name, *args, &block)
      if client.respond_to?(method_name)
        return client.send(method_name, *args, &block)
      end

      super
    end
  end
end

Cryptoprocessing.setup

require 'cryptoprocessing/rails' if defined?(::Rails::Engine)
