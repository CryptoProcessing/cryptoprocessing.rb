require 'cryptoprocessing/api/api_client'
require 'cryptoprocessing/api/client'
require 'thor'

module Cryptoprocessing
  class CLI < Thor
    class_option :verbose, :type => :boolean
    class_option :api_url
    class_option :access_token

    def initialize(*args)
      super
      config = {:access_token => 'some'}
      config[:api_url] = options[:api_url] if options[:api_url]

      puts config

      @client = Cryptoprocessing::APIClient.new(config)
    end

    desc "register EMAIL PASSWORD", "register user at Cryptoprocessing"

    def register(email, password)
      @client.register({:email => email, :password => password})
    end

    desc "login EMAIL PASSWORD", "login to Cryptoprocessing"

    def login(email, password)

    end

    desc "create_address NAME", "add address to NAME"

    def create_address()

    end

    desc "addresses NAME", "addresses to NAME"

    def addresses()

    end

    desc "address NAME", "show address to NAME"

    def address()

    end

    desc "transactions NAME", "say hello to NAME"

    def transactions()

    end

    desc "transactions_by_address NAME", "say hello to NAME"

    def transactions_by_address()

    end

    desc "send_raw_transaction NAME", "say hello to NAME"

    def send_raw_transaction()

    end

    desc "create_transaction NAME", "say hello to NAME"

    def create_transaction()

    end
  end
end
