module Cryptoprocessing
  class APIObject < Hash
    def initialize(client, data)
      super()
      update(data)
      @client = client
    end

    def update(data)
      return if data.nil?
      data.each {|key, val| self[key] = val} if data.is_a?(Hash)
    end
  end
end
