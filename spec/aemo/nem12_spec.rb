require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))
require 'json'

describe AEMO::NEM12 do
  describe '::RECORD_INDICATORS' do
    it "should be a hash" do
      expect(AEMO::NEM12::RECORD_INDICATORS.class).to eq(Hash)
    end
  end
  
  describe '.valid_nmi?' do
    it 'should validate nmi' do
      JSON.parse(File.read(File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures','nmi_checksum.json')))).each do |nmi|
        expect(AEMO::NEM12.valid_nmi?(nmi['nmi'])).to eq(true)
      end
    end
  end
  
  describe '#nmi_checksum' do
    it 'should return nmi checksum' do
      JSON.parse(File.read(File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures','nmi_checksum.json')))).each do |nmi|
        nem12 = AEMO::NEM12.new(nmi['nmi'])
        expect(nem12.nmi_checksum).to eq(nmi['checksum'])
      end
    end
  end
  
  describe '#parse_nem12' do
  end
  
  describe '.parse_nem12_file' do
    it 'should parse a file' do
      Dir.entries(File.join(File.dirname(__FILE__),'..','fixtures','NEM12')).reject{|f| %w(. .. .DS_Store).include?(f)}.each do |file|
        puts file
        nem12 = AEMO::NEM12.parse_nem12_file(File.join(File.dirname(__FILE__),'..','fixtures','NEM12',file))
      end
    end
  end
  
  describe 'parse_nem12_100' do
  end
  
  describe 'parse_nem12_200' do
  end
  
  describe 'parse_nem12_300' do
  end
  
  describe 'parse_nem12_400' do
  end
  
  describe 'parse_nem12_500' do
  end
  
  describe 'parse_nem12_900' do
  end
  
end
