# frozen_string_literal: true
# encoding: UTF-8

$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'aemo/version'

Gem::Specification.new do |s|
  s.name          = 'aemo'
  s.version       = AEMO::VERSION
  s.platform      = Gem::Platform::RUBY
  s.date          = '2018-05-16'
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

  s.required_ruby_version = '>= 2.3.0'

  # Production Dependencies
  s.add_dependency 'activesupport', '>= 4.2.6', '< 5.2'
  s.add_dependency 'httparty',  '~> 0.15', '>= 0.15.6'
  s.add_dependency 'json',      '>= 1.7.5'
  s.add_dependency 'multi_xml', '~> 0.6', '>= 0.5.0'
  s.add_dependency 'nokogiri',  '~> 1.8', '>= 1.8.2'

  # Development Dependencies
  s.add_development_dependency 'awesome_print', '~> 1.8', '>= 1.8.0'
  s.add_development_dependency 'coveralls', '~> 0.8', '>= 0.8.21'
  s.add_development_dependency 'guard-yard', '~> 2.2', '>= 2.2.0'
  s.add_development_dependency 'jeweler', '~> 2.3', '>= 2.3.7'
  s.add_development_dependency 'listen', '~> 3.1', '= 3.1.5'
  s.add_development_dependency 'rdoc', '~> 5.1', '>= 5.1.0'
  s.add_development_dependency 'rspec', '~> 3.7', '>= 3.7.0'
  s.add_development_dependency 'rubocop', '~> 0.52.1', '>= 0.52.1'
  s.add_development_dependency 'simplecov', '~> 0.14', '>= 0.14.1'
  s.add_development_dependency 'timecop', '~> 0.9', '>= 0.9.1'
  s.add_development_dependency 'webmock', '~> 3.1', '>= 3.1.0'
  s.add_development_dependency 'yard', '~> 0.9', '>= 0.9.11'
end
