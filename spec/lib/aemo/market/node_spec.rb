# frozen_string_literal: true

require 'spec_helper'

describe AEMO::Market::Node do
  describe '.IDENTIFIERS' do
    it 'is an array' do
      expect(AEMO::Market::Node::IDENTIFIERS).to be_instance_of(Array)
    end
  end

  describe 'creating a node' do
    it 'raises an error if invalid region' do
      expect { described_class.new('BOTTOMS') }.to raise_error(ArgumentError)
    end

    it 'creates if node valid' do
      expect { described_class.new('NSW') }.not_to raise_error
    end
  end

  describe 'AEMO::Region instance methods' do
    before do
      @nsw = described_class.new('NSW')
    end

    describe 'AEMO::Region dispatch information' do
      it 'returns current dispatch data' do
        expect(@nsw.current_dispatch.count).to eq(AEMO::Market.current_dispatch(@nsw.identifier).count)
      end

      it 'returns current trading data' do
        expect(@nsw.current_trading.count).to eq(AEMO::Market.current_trading(@nsw.identifier).count)
      end
    end
  end
end
