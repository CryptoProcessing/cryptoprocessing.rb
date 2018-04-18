# frozen_string_literal: true
# -*- ruby -*-
# encoding: utf-8
# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cryptoprocessing/version'

Gem::Specification.new do |spec|
  spec.name = 'cryptoprocessing'
  spec.version = Cryptoprocessing::VERSION.dup
  spec.authors = ['Arthur Chafonov']
  spec.email = ['actuosus@gmail.com']

  spec.summary = 'Client for accessing Cryptoprocessing API'
  spec.description = 'Gem to access Blockchain Cryptoprocessing Platform API'
  spec.homepage = 'https://github.com/oomag/cryptoprocessing-api-client'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(\.idea|test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.platform = Gem::Platform::RUBY

  spec.add_dependency 'logging', '~> 2.0'
  spec.add_dependency 'thor', '~> 0.19'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'webmock'
end
