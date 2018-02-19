RSpec.describe Cryptoprocessing do
  before do
    Cryptoprocessing.reset!
  end

  after do
    Cryptoprocessing.reset!
  end

  it 'sets defaults' do
    Cryptoprocessing::Configurable.keys.each do |key|
      expect(Cryptoprocessing.instance_variable_get(:"@#{key}")).to eq(Cryptoprocessing::Default.send(key))
    end
  end

  RSpec.describe '.client' do
    it 'creates an Cryptoprocessing::Client' do
      expect(Cryptoprocessing.client).to be_kind_of Cryptoprocessing::Client
    end
    it 'caches the client when the same options are passed' do
      expect(Cryptoprocessing.client).to eq(Cryptoprocessing.client)
    end
    it 'returns a fresh client when options are not the same' do
      client = Cryptoprocessing.client
      Cryptoprocessing.access_token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE1MTg3OTgxODcsInN1YiI6ImQ2NjRkZmJjLTQ3MmYtNGJjZC1hMjEzLWQxZDFiYjYzY2QxMSJ9.qHSp6uey_QwJe9ub939VK8SwBO1SPHrQOJPc_Tvl2Rs'
      client_two = Cryptoprocessing.client
      client_three = Cryptoprocessing.client
      expect(client).not_to eq(client_two)
      expect(client_three).to eq(client_two)
    end
  end

  RSpec.describe '.configure' do
    Cryptoprocessing::Configurable.keys.each do |key|
      it "sets the #{key.to_s.gsub('_', ' ')}" do
        Cryptoprocessing.configure do |config|
          config.send("#{key}=", key)
        end
        expect(Cryptoprocessing.instance_variable_get(:"@#{key}")).to eq(key)
      end
    end
  end

  it 'has a version number' do
    expect(Cryptoprocessing::VERSION).not_to be nil
  end
end