require 'spec_helper'

describe AEMO::Market do
  describe '.regions' do
    it "returns the SupportedFormats constant" do
      expect(AEMO::Market.regions).to eq(AEMO::Region::REGIONS)
    end

    it "returns the SupportedFormats constant for subclasses" do
      class MyParser < HTTParty::Parser
        SupportedFormats = {"application/atom+xml" => :atom}
      end
      expect(MyParser.formats).to eq({"application/atom+xml" => :atom})
    end
  end
end
