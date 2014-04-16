require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe AEMO::Market do
  describe '.regions' do
    it "returns the SupportedFormats constant" do
      AEMO::Market.regions.should == AEMO::Region::REGIONS
    end

    it "returns the SupportedFormats constant for subclasses" do
      class MyParser < HTTParty::Parser
        SupportedFormats = {"application/atom+xml" => :atom}
      end
      MyParser.formats.should == {"application/atom+xml" => :atom}
    end
  end
end