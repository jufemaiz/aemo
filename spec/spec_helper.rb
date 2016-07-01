require 'coveralls'
require 'simplecov'
require 'pry'
require 'webmock/rspec'
require 'timecop'
require 'aemo'

WebMock.disable_net_connect!(allow_localhost: true)

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]
)
SimpleCov.start

RSpec.configure do |config|
  # WebMock
  config.before(:each) do
    csv_headers = { 'Content-Type' => 'text/csv' }
    xml_headers = { 'Content-Type' => 'text/xml' }

    # Market Data
    stub_request(:get, 'http://www.nemweb.com.au/mms.GRAPHS/GRAPHS/GRAPH_5NSW1.csv')
      .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: File.new('spec/fixtures/Market/GRAPH_5NSW1.csv'), headers: csv_headers)
    stub_request(:get, 'http://www.nemweb.com.au/mms.GRAPHS/GRAPHS/GRAPH_30NSW1.csv')
      .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: File.new('spec/fixtures/Market/GRAPH_30NSW1.csv'), headers: csv_headers)
    stub_request(:get, 'http://www.nemweb.com.au/mms.GRAPHS/data/DATA201501_NSW1.csv')
      .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: File.new('spec/fixtures/Market/DATA201501_NSW1.csv'), headers: csv_headers)
    stub_request(:get, 'http://www.nemweb.com.au/mms.GRAPHS/data/DATA201502_NSW1.csv')
      .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: File.new('spec/fixtures/Market/DATA201502_NSW1.csv'), headers: csv_headers)

    # MSATS
    stub_request(:get, %r{msats.prod.nemnet.net.au\/msats\/ws\/C4\/ER})
      .with(headers: { 'Accept' => ['text/xml'], 'Content-Type' => 'text/xml' })
      .to_return(status: 200, body: File.new('spec/fixtures/MSATS/c4.xml'), headers: xml_headers)
    stub_request(:get, %r{msats.prod.nemnet.net.au\/msats\/ws\/MSATSLimits\/ER})
      .with(headers: { 'Accept' => ['text/xml'], 'Content-Type' => 'text/xml' })
      .to_return(status: 200, body: File.new('spec/fixtures/MSATS/msats_limits.xml'), headers: xml_headers)
    stub_request(:get, %r{msats.prod.nemnet.net.au\/msats\/ws\/NMIDetail\/ER})
      .with(headers: { 'Accept' => ['text/xml'], 'Content-Type' => 'text/xml' })
      .to_return(status: 200, body: File.new('spec/fixtures/MSATS/nmi_details.xml'), headers: xml_headers)
    stub_request(:get, %r{msats.prod.nemnet.net.au\/msats\/ws\/NMIDiscovery\/ER})
      .with(headers: { 'Accept' => ['text/xml'], 'Content-Type' => 'text/xml' })
      .to_return(status: 200, body: File.new('spec/fixtures/MSATS/nmi_discovery_by_address.xml'), headers: xml_headers)
    stub_request(:get, %r{msats.prod.nemnet.net.au\/msats\/ws\/ParticipantSystemStatus\/ER})
      .with(headers: { 'Accept' => 'text/xml', 'Content-Type' => 'text/xml' })
      .to_return(status: 200, body: File.new('spec/fixtures/MSATS/participant_system_status.xml'), headers: xml_headers)
    # MSATS ERRORS
    stub_request(:get, %r{msats.prod.nemnet.net.au\/msats\/ws\/C4\/ER\?.+?NMI=4001234566.+?})
      .with(headers: { 'Accept' => ['text/xml'], 'Content-Type' => 'text/xml' })
      .to_return(status: 404, body: '', headers: xml_headers)
    stub_request(:get, %r{msats.prod.nemnet.net.au\/msats\/ws\/NMIDetail\/ER\?.+?nmi=4001234566.+?})
      .with(headers: { 'Accept' => ['text/xml'], 'Content-Type' => 'text/xml' })
      .to_return(status: 404, body: '', headers: xml_headers)
  end

  config.order = 'random'
end

def fixture(filename)
  path = "#{File.dirname(__FILE__)}/fixtures/#{filename}"
  File.open(path)
end
