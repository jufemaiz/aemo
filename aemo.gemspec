# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'aemo/version'

Gem::Specification.new do |s|
  s.name          = 'aemo'
  s.version       = AEMO::VERSION
  s.platform      = Gem::Platform::RUBY
  s.date          = '2016-02-16'
  s.summary       = 'Gem providing functionality for the Australian Energy Market Operator data'
  s.description   = 'Gem providing functionality for the Australian Energy Market Operator data'
  s.authors       = ['Joel Courtney','Stuart Auld']
  s.email         = ['jcourtney@cozero.com.au','sauld@cozero.com.au']
  s.homepage      = 'https://github.com/jufemaiz/aemo'
  s.license       = 'MIT'
  s.files         = Dir["lib/**/*", "spec/**/*", "bin/*"]
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.required_ruby_version     = '>= 1.9.3'

  s.add_dependency 'json',      '~> 1.8'
  s.add_dependency 'nokogiri',  '~> 1.6', '>= 1.6.6'
  s.add_dependency 'zip',       '~>2.0'
  s.add_dependency 'multi_xml', '~> 0.5',   '>= 0.5.2'
  s.add_dependency 'httparty',  '~> 0.13',  '>= 0.13.1'
  s.add_dependency 'activesupport'

  s.add_development_dependency 'bundler', "~> 1.3"
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'jeweler'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-nav'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'guard-yard'

end
