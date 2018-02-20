require 'bundler/setup'

if RUBY_ENGINE == 'ruby'
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new [
                                                                     SimpleCov::Formatter::HTMLFormatter,
                                                                     Coveralls::SimpleCov::Formatter
                                                                 ]
  SimpleCov.start
end

require 'webmock/rspec'
require 'faker'
require 'cryptoprocessing'

SPEC_DIR = File.expand_path(File.dirname(__FILE__))
ROOT_DIR = File.expand_path(File.join(SPEC_DIR, '..'))

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
