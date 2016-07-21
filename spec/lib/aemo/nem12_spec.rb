require 'spec_helper'
require 'json'

describe AEMO::NEM12 do
  let(:json) { JSON.parse(fixture('nmi_checksum.json').read) }

  describe '::RECORD_INDICATORS' do
    it 'should be a hash' do
      expect(AEMO::NEM12::RECORD_INDICATORS.class).to eq(Hash)
    end
  end

  describe '#parse_nem12' do
  end

  describe '.parse_nem12_file' do
    it 'should parse a file' do
      Dir.entries(File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'NEM12')).reject { |f| %w(. .. .DS_Store).include?(f) }.each do |file|
        puts "File: #{file}"
        nem12_data = AEMO::NEM12.parse_nem12_file(fixture(File.join('NEM12', file)))
        puts "NEM12: #{nem12_data.inspect}"
        expect(nem12_data.length).not_to eq(0)
      end
    end
  end

  describe '#parse_nem12_100' do
    it 'should raise datetime error' do
      expect { AEMO::NEM12.parse_nem12_100('100,NEM12,666,CNRGYMDP,NEMMCO') }.to raise_error(ArgumentError)
    end
    it 'should raise datetime error' do
      expect { AEMO::NEM12.parse_nem12_100('100,NEM12,666,CNRGYMDP,NEMMCO', strict: true) }.to raise_error(ArgumentError)
    end
    it 'should not raise an error' do
      expect { AEMO::NEM12.parse_nem12_100('100,NEM12,201603010000,CNRGYMDP,NEMMCO', strict: true) }.not_to raise_error
    end
  end

  describe '#parse_nem12_200' do
    # before(:each) do
    #   @nem12 = AEMO::NEM12.parse_nem12_100('100,NEM12,201603010000,CNRGYMDP,NEMMCO', strict: true)
    # end
  end

  describe '#parse_nem12_300' do
  end

  describe '#parse_nem12_400' do
  end

  describe '#parse_nem12_500' do
  end

  describe '#parse_nem12_900' do
  end

  describe '#flag_to_s' do
  end
end
