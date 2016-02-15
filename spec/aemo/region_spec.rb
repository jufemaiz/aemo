require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe AEMO::Region do
  describe '.REGIONS' do
    it "should be a hash" do
      expect(AEMO::Market.regions).to be_instance_of(Hash)
    end
  end
end
