require 'cryptoprocessing'
require 'thor'
require 'json/ext'

module Cryptoprocessing
  class CLI < Thor
    class_option :verbose, :type => :boolean
    class_option :api_endpoint
    class_option :api_namespace
    class_option :access_token

    def initialize(*args)
      super
      config = {}
      config[:api_endpoint] = options[:api_endpoint] if options[:api_endpoint]
      config[:api_namespace] = options[:api_namespace] if options[:api_namespace]
      config[:access_token] = options[:access_token] if options[:access_token]

      @client = Cryptoprocessing::Client.new(config)
    end

    desc "register EMAIL PASSWORD", "Register user at Cryptoprocessing with EMAIL and PASSWORD"

    def register(email, password)
      output = []
      response = @client.register({:email => email, :password => password})
      output << response['message']
      output = output.join("\n")
      puts output
    end

    desc "login EMAIL PASSWORD", "Login user to Cryptoprocessing using EMAIL and PASSWORD"

    def login(email, password)
      output = []
      response = @client.login({:email => email, :password => password})
      output << response['message']
      output = output.join("\n")
      puts output
    end

    desc "create_account CURRENCY NAME", "Create account for user with NAME"

    def create_account(currency, name)
      output = []
      response = @client.create_account({:currency => currency, :name => name})
      output << "Account with ID #{response['account_id']} created."
      output = output.join("\n")
      puts output
    end

    desc "account ACCOUNT_ID", "Get account info by ACCOUNT_ID"

    def account(account_id, currency = nil)
      output = []
      response = @client.account(account_id,{:currency => currency})
      output << "Account #{account_id} info:"
      output << JSON.pretty_generate(response['data'])
      output = output.join("\n")
      puts output
    end

    desc "create_address NAME", "Add address to NAME"

    def create_address(account_id, name = nil)
      output = []
      response = @client.create_address(account_id, {:name => name})
      output << "Address with ID #{response['id']} created."
      output = output.join("\n")
      puts output
    end

    desc "addresses ACCOUNT_ID", "Addresses for ACCOUNT_ID"

    def addresses(account_id)
      output = []
      response = @client.addresses(account_id)
      if response.kind_of?(Array) and response.length == 0
        output << "No addresses for account #{account_id}."
      elsif response['addresses'].kind_of?(Array) && response['transactions'].length > 0
        output << "Addresses for account #{account_id}:"
        output << JSON.pretty_generate(response)
      else
        output << "No addresses for account #{account_id}."
      end
      output = output.join("\n")
      puts output
    end

    desc "address ACCOUNT_ID ADDRESS", "Show address info for ACCOUNT_ID and ADDRESS"

    def address(account_id, address)
      output = []
      response = @client.address(account_id, address)
      output << "Address #{address} for account #{account_id} info:"
      output << JSON.pretty_generate(response)
      output = output.join("\n")
      puts output
    end

    desc "transactions ACCOUNT_ID", "List transactions by ACCOUNT_ID"

    def transactions(account_id)
      output = []
      response = @client.transactions(account_id)
      if response.kind_of?(Array) and response.length == 0
        output << "No transactions for account #{account_id} and address #{account_id}."
      elsif response['transactions'].kind_of?(Array) && response['transactions'].length > 0
        output << "Transactions for account #{account_id}:"
        output << JSON.pretty_generate(response['transactions'])
      else
        output << "No transactions for account #{account_id}."
      end
      output = output.join("\n")
      puts output
    end

    desc "transactions_by_address ACCOUNT_ID ADDRESS", "List transactions from ACCOUNT_ID with address ADDRESS"

    def transactions_by_address(account_id, address)
      output = []
      response = @client.transactions_by_address(account_id, address)
      if response.kind_of?(Array) and response.length == 0
        output << "No transactions for account #{account_id} and address #{address}."
      elsif response['transactions'].kind_of?(Array) && response['transactions'].length > 0
        output << "Transactions for account #{account_id} and address #{address}:"
        output << JSON.pretty_generate(response['transactions'])
      else
        output << "No transactions for account #{account_id} and address #{address}."
      end
      output = output.join("\n")
      puts output
    end

    desc "send_raw_transaction RAW_TRANSACTION_ID DESCRIPTION", "Send RAW_TRANSACTION_ID with DESCRIPTION"

    def send_raw_transaction(raw_transaction_id, description = nil)
      output = []
      response = @client.send_raw_transaction({
                                                  :raw_transactions_id => raw_transaction_id,
                                                  :description => description
                                              })
      output << response['message']
      output = output.join("\n")
      puts output
    end

    desc "create_transaction ACCOUNT_ID FROM TO AMOUNT DESCRIPTION IDEM", "Create transaction record"

    def create_transaction(account_id, from_address, to_address, amount, description = nil, idem = nil)
      output = []
      response = @client.create_transaction(account_id, {
          :from => [from_address],
          :to => [{:amount => amount, :address => to_address}],
          :description => description,
          :idem => idem
      })
      output << response['message']
      output = output.join("\n")
      puts output
    end
  end
end
