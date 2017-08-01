# frozen_string_literal: true
# encoding: UTF-8

$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'aemo/version'

Gem::Specification.new do |s|
  s.name          = 'aemo'
  s.version       = AEMO::VERSION
  s.platform      = Gem::Platform::RUBY
  s.date          = '2016-11-04'
  s.summary       = 'Gem providing functionality for the Australian Energy Market Operator data'
  s.description   = 'Gem providing functionality for the Australian Energy Market Operator data. Supports NMIs, NEM12, MSATS Web Services and more'
  s.authors       = ['Joel Courtney', 'Stuart Auld', 'Neil Parikh']
  s.email         = ['jcourtney@cozero.com.au', 'sauld@cozero.com.au', 'nparikh@cozero.com.au']
  s.homepage      = 'https://github.com/jufemaiz/aemo'
  s.license       = 'MIT'
  s.files         = Dir['lib/**/*', 'spec/**/*', 'bin/*']
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 1.9.3'

  # Production Dependencies
  s.add_dependency 'json',      '~> 1.8'
  s.add_dependency 'nokogiri',  '~> 1.6', '>= 1.6.8'
  s.add_dependency 'rubyzip',   '~> 1.2', '>= 1.2.1'
  s.add_dependency 'multi_xml', '~> 0.5',   '>= 0.5.2'
  s.add_dependency 'httparty',  '~> 0.13',  '>= 0.13.1'
  s.add_dependency 'activesupport', '~> 4.2', '>= 4.2.6'

  # Development Dependencies
  # s.add_development_dependency 'bundler', '~> 1.12', '>= 1.12.5'
  s.add_development_dependency 'listen', '~> 3.0', '= 3.0.8'
  s.add_development_dependency 'rspec', '~> 3.4', '>= 3.4.0'
  s.add_development_dependency 'rdoc', '~> 4.2', '>= 4.2.2'
  s.add_development_dependency 'jeweler', '~> 2.1', '>= 2.1.1'
  s.add_development_dependency 'simplecov', '~> 0.11', '>= 0.11.2'
  s.add_development_dependency 'coveralls', '~> 0.8', '>= 0.8.13'
  s.add_development_dependency 'awesome_print', '~> 1.7', '>= 1.7.0'
  s.add_development_dependency 'pry', '~> 0.10', '>= 0.10.3'
  s.add_development_dependency 'pry-nav', '~> 0.2', '>= 0.2.4'
  s.add_development_dependency 'yard', '~> 0.8.7', '>= 0.8.7.6'
  s.add_development_dependency 'guard-yard', '~> 2.1', '>= 2.1.3'
  s.add_development_dependency 'webmock', '~> 2.1', '>= 2.1.0'
  s.add_development_dependency 'rubocop', '~> 0.41', '>= 0.41.1'
  s.add_development_dependency 'timecop', '~> 0.8', '>= 0.8.1'
end
