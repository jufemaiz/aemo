# frozen_string_literal: true

require 'spec_helper'

describe AEMO::Region do
  describe '.REGIONS' do
    it 'is a hash' do
      expect(AEMO::Region::REGIONS).to be_instance_of(Hash)
    end
  end

  describe 'creating a region' do
    it 'raises an error if invalid region' do
      expect { described_class.new('BOTTOMS') }.to raise_error(ArgumentError)
    end

    it 'creates if region valid' do
      expect { described_class.new('NSW') }.not_to raise_error
    end
  end

  describe 'AEMO::Region instance methods' do
    before do
      @nsw = described_class.new('NSW')
    end

    it 'has an abbreviation' do
      expect(@nsw.abbr).to eq('NSW')
    end

    it 'has a fullname' do
      expect(@nsw.fullname).to eq('New South Wales')
    end

    it 'has to_s method' do
      expect(@nsw.to_s).to eq('NSW')
    end

    it 'has a valid region' do
      expect(@nsw.send(:valid_region?, 'NSW')).to be(true)
    end

    it 'has return invalid for invalid region' do
      expect(@nsw.send(:valid_region?, 'BOB')).to be(false)
    end

    describe 'AEMO::Region dispatch information' do
      it 'returns current dispatch data' do
        expect(@nsw.current_dispatch.count).to eq(AEMO::Market.current_dispatch(@nsw.abbr).count)
      end

      it 'returns current trading data' do
        expect(@nsw.current_trading.count).to eq(AEMO::Market.current_trading(@nsw.abbr).count)
      end
    end
  end

  describe 'AEMO::Region class methods' do
    it 'returns all regions' do
      expect(described_class.all.count).to eq(AEMO::Region::REGIONS.keys.count)
    end
  end
end
