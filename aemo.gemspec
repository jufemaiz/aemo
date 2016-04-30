# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'aemo/version'

Gem::Specification.new do |s|
  s.name          = 'aemo'
  s.version       = AEMO::VERSION
  s.platform      = Gem::Platform::RUBY
  s.date          = '2016-02-16'
  s.summary       = 'Gem providing functionality for the Australian Energy Market Operator data'
  s.description   = 'Gem providing functionality for the Australian Energy Market Operator data. Supports NMIs, NEM12, MSATS Web Services and more'
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
  s.add_dependency 'rubyzip',   '~> 1.1.7'
  s.add_dependency 'multi_xml', '~> 0.5',   '>= 0.5.2'
  s.add_dependency 'httparty',  '~> 0.13',  '>= 0.13.1'
  s.add_dependency 'activesupport', '~> 4.2', '>= 4.2.6'

  s.add_development_dependency 'bundler', "~> 1.3"
  s.add_development_dependency 'rspec'#, '~> 0'
  s.add_development_dependency 'rdoc', '~> 4.2'
  s.add_development_dependency 'jeweler'#, '~> 0'
  s.add_development_dependency 'simplecov'#, '~> 0'
  s.add_development_dependency 'coveralls', '~> 0.8', '>= 0.8.13'
  s.add_development_dependency 'awesome_print'#, '~> 0'
  s.add_development_dependency 'pry'#, '~> 0'
  s.add_development_dependency 'pry-nav'#, '~> 0'
  s.add_development_dependency 'yard'#, '~> 0'
  s.add_development_dependency 'guard-yard'#, '~> 0'
  s.add_development_dependency 'webmock'#, '~> 0'

end
