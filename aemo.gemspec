# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'aemo'
  s.version     = '0.1.4'
  s.platform    = Gem::Platform::RUBY
  s.date        = '2014-12-05'
  s.summary     = 'AEMO Gem'
  s.description = 'Gem providing functionality for the Australian Energy Market Operator data'
  s.authors     = ['Joel Courtney']
  s.email       = ['jcourtney@cozero.com.au']
  s.homepage    =
    'https://bitbucket.org/jufemaiz/aemo-gem'
  s.license       = 'MIT'
  
  s.required_ruby_version     = '>= 1.9.3'

  s.add_dependency 'json',      '~> 1.8'
  s.add_runtime_dependency 'multi_xml', '~> 0.5',   '>= 0.5.2'
  s.add_runtime_dependency 'httparty',   '~> 0.13',  '>= 0.13.1'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end