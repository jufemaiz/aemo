require 'spec_helper'

describe AEMO::Region do
  describe '.REGIONS' do
    it 'should be a hash' do
      expect(AEMO::Region::REGIONS).to be_instance_of(Hash)
    end
  end

  describe 'creating a region' do
    it 'should raise an error if invalid region' do
      expect { AEMO::Region.new('BOTTOMS') }.to raise_error(ArgumentError)
    end
    it 'should create if region valid' do
      expect { AEMO::Region.new('NSW') }.not_to raise_error
    end
  end

  describe 'AEMO::Region instance methods' do
    before(:each) do
      @nsw = AEMO::Region.new('NSW')
    end
    it 'should have an abbreviation' do
      expect(@nsw.abbr).to eq('NSW')
    end
    it 'should have a fullname' do
      expect(@nsw.fullname).to eq('New South Wales')
    end
    it 'should have to_s method' do
      expect(@nsw.to_s).to eq('NSW')
    end

    it 'should have a valid region' do
      expect(@nsw.send(:valid_region?, 'NSW')).to eq(true)
    end

    it 'should have return invalid for invalid region' do
      expect(@nsw.send(:valid_region?, 'BOB')).to eq(false)
    end

    describe 'AEMO::Region dispatch information' do
      it 'should return current dispatch data' do
        expect(@nsw.current_dispatch.count).to eq(AEMO::Market.current_dispatch(@nsw.abbr).count)
      end
      it 'should return current trading data' do
        expect(@nsw.current_trading.count).to eq(AEMO::Market.current_trading(@nsw.abbr).count)
      end
    end
  end

  describe 'AEMO::Region class methods' do
    it 'should return all regions' do
      expect(AEMO::Region.all.count).to eq(AEMO::Region::REGIONS.keys.count)
    end
  end
end
