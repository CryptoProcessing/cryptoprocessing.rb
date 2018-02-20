# Cryptoprocessing

Ruby Gem to access and interact with [Cryptoprocessing API](https://api.cryptoprocessing.io).

To experiment with that code, run `bin/console` for an interactive prompt.

[![Build Status](https://travis-ci.org/oomag/cryptoprocessing.rb.svg?branch=master)](https://travis-ci.org/oomag/cryptoprocessing.rb)
[![Coverage Status](https://coveralls.io/repos/github/oomag/cryptoprocessing.rb/badge.svg?branch=master)](https://coveralls.io/github/oomag/cryptoprocessing.rb?branch=master)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cryptoprocessing'
```

And then execute:

    $ bundle

Or install it manually as:

    $ gem install cryptoprocessing

## Usage

```ruby
require 'cryptoprocessing'

# Authenticate using email and password
client = Cryptoprocessing::Client.new(:email => '<EMAIL>', :password => '<PASSWORD>')

# or

# Using block
Cryptoprocessing.configure do |c|
  c.email = '<EMAIL>'
  c.password = '<PASSWORD>'
end

# or

client = Cryptoprocessing::Client.new(:access_token => '<TOKEN>')
client.account('<ACCOUNT_ID>')

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/oomag/cryptoprocessing-api-client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Cryptoprocessing project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/oomag/cryptoprocessing-api-client/blob/master/CODE_OF_CONDUCT.md).
