require 'coveralls'
require 'simplecov'
require 'pry'
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
])
SimpleCov.start

require "aemo"

RSpec.configure do |config|
  # WebMock
  config.before(:each) do
    # Market Data
    stub_request(:get, "http://www.nemweb.com.au/mms.GRAPHS/GRAPHS/GRAPH_5NSW1.csv").
      with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
      to_return(status: 200, body: File.new('spec/fixtures/GRAPH_5NSW1.csv'), headers: {'Content-Type'=>'text/csv'})
    stub_request(:get, 'http://www.nemweb.com.au/mms.GRAPHS/GRAPHS/GRAPH_30NSW1.csv').
      with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
      to_return(status: 200, body: File.new('spec/fixtures/GRAPH_30NSW1.csv'), headers: {'Content-Type'=>'text/csv'})

    # MSATS
    stub_request(:get, /msats.prod.nemnet.net.au\/msats\/ws\/C4\/ER/).
      with(headers: {'Accept'=>['text/xml'], 'Content-Type'=>'text/xml'}).
      to_return(status: 200, body: File.new('spec/fixtures/MSATS/c4.xml'), headers: {'Content-Type'=>'text/xml'})
    stub_request(:get, /msats.prod.nemnet.net.au\/msats\/ws\/MSATSLimits\/ER/).
      with(headers: {'Accept'=>['text/xml'], 'Content-Type'=>'text/xml'}).
      to_return(status: 200, body: File.new('spec/fixtures/MSATS/msats_limits.xml'), headers: {'Content-Type'=>'text/xml'})
    stub_request(:get, /msats.prod.nemnet.net.au\/msats\/ws\/NMIDetail\/ER/).
      with(headers: {'Accept'=>['text/xml'], 'Content-Type'=>'text/xml'}).
      to_return(status: 200, body: File.new('spec/fixtures/MSATS/nmi_details.xml'), headers: {'Content-Type'=>'text/xml'})
    stub_request(:get, /msats.prod.nemnet.net.au\/msats\/ws\/NMIDiscovery\/ER/).
      with(headers: {'Accept'=>['text/xml'], 'Content-Type'=>'text/xml'}).
      to_return(status: 200, body: File.new('spec/fixtures/MSATS/nmi_discovery_by_address.xml'), headers: {'Content-Type'=>'text/xml'})
    stub_request(:get, /msats.prod.nemnet.net.au\/msats\/ws\/ParticipantSystemStatus\/ER/).
      with(headers: {'Accept'=>'text/xml', 'Content-Type'=>'text/xml'}).
      to_return(status: 200, body: File.new('spec/fixtures/MSATS/participant_system_status.xml'), headers: {'Content-Type'=>'text/xml'})
    # MSATS ERRORS
    stub_request(:get, /msats.prod.nemnet.net.au\/msats\/ws\/C4\/ER\?.+?NMI=4001234566.+?/).
      with(headers: {'Accept'=>['text/xml'], 'Content-Type'=>'text/xml'}).
      to_return(status: 404, body: "", headers: {'Content-Type'=>'text/xml'})
    stub_request(:get, /msats.prod.nemnet.net.au\/msats\/ws\/NMIDetail\/ER\?.+?nmi=4001234566.+?/).
      with(headers: {'Accept'=>['text/xml'], 'Content-Type'=>'text/xml'}).
      to_return(status: 404, body: "", headers: {'Content-Type'=>'text/xml'})
  end

  config.order = "random"

end

def fixture(filename)
  path = "#{File.dirname(__FILE__)}/fixtures/#{filename}"
  File.open(path)
end
