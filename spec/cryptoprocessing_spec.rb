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

  it 'has a version number' do
    expect(Cryptoprocessing::VERSION).not_to be nil
  end
end