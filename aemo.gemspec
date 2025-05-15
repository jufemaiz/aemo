# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'aemo/version'

Gem::Specification.new do |s|
  s.name          = 'aemo'
  s.version       = AEMO::VERSION
  s.platform      = Gem::Platform::RUBY
  s.summary       = 'Gem providing functionality for the Australian Energy Market Operator data'
  s.description   = 'Gem providing functionality for the Australian Energy Market Operator data.' \
                    'Supports NMIs, NEM12, MSATS Web Services and more'
  s.authors       = ['Joel Courtney', 'Stuart Auld', 'Neil Parikh', 'Olivier Nsabimana']
  s.email         = [
    'joel@aceteknologi.com', 'stuart@aceteknologi.com',
    'neilparikh107@gmail.com', 'onsabimana@cozero.com.au'
  ]
  s.homepage      = 'https://github.com/jufemaiz/aemo'
  s.license       = 'MIT'
  s.files         = Dir['lib/**/*', 'spec/**/*', 'bin/*']
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 3.1.0'

  # Production Dependencies
  s.add_dependency 'activesupport', '>= 4.2.6', '< 7.2'
  s.add_dependency 'httparty', '~> 0.21', '>= 0.21.0'
  s.add_dependency 'json', '>= 1.7.5', '< 3'
  s.add_dependency 'multi_xml', '~> 0.6', '>= 0.5.0'
  s.add_dependency 'nokogiri',  '~> 1.14', '>= 1.14.3'
  s.add_dependency 'rexml', '~> 3.3', '>= 3.3.3'

  # Stay safe!
  s.metadata['rubygems_mfa_required'] = 'true'
end
