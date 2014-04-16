require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe AEMO::NEM12 do
  describe '.RECORD_INDICATORS' do
    it "should be a hash" do
      AEMO::NEM12.RECORD_INDICATORS.should be_instance_of(Hash)
    end
  end
  
  describe '.valid_nmi?' do
    it 'should validate nmi' do
    end
  end
  
  describe '.nmi_checksum' do
    it 'should return nmi checksum' do
      
    end
  end
end
