require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))
require 'json'

describe AEMO::NEM12 do
  describe '::RECORD_INDICATORS' do
    it "should be a hash" do
      AEMO::NEM12::RECORD_INDICATORS.should be_instance_of(Hash)
    end
  end
  
  describe '.valid_nmi?' do
    it 'should validate nmi' do
      JSON.parse(File.read(File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures','nmi_checksum.json')))).each do |nmi|
        AEMO::NEM12.valid_nmi?(nmi['nmi']).should == true
      end
    end
  end
  
  describe '#nmi_checksum' do
    it 'should return nmi checksum' do
      JSON.parse(File.read(File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures','nmi_checksum.json')))).each do |nmi|
        nem12 = AEMO::NEM12.new(nmi['nmi'])
        nem12.nmi_checksum.should == nmi['checksum']
      end
    end
  end
  
  describe 'parse_nem12' do
  end
  
  describe 'parse_nem12_file' do
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
