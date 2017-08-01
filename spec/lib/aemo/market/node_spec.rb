# frozen_string_literal: true

require 'spec_helper'

describe AEMO::Market::Node do
  describe '.IDENTIFIERS' do
    it 'should be an array' do
      expect(AEMO::Market::Node::IDENTIFIERS).to be_instance_of(Array)
    end
  end

  describe 'creating a node' do
    it 'should raise an error if invalid region' do
      expect { AEMO::Market::Node.new('BOTTOMS') }.to raise_error(ArgumentError)
    end
    it 'should create if node valid' do
      expect { AEMO::Market::Node.new('NSW') }.not_to raise_error
    end
  end

  describe 'AEMO::Region instance methods' do
    before(:each) do
      @nsw = AEMO::Market::Node.new('NSW')
    end

    describe 'AEMO::Region dispatch information' do
      it 'should return current dispatch data' do
        expect(@nsw.current_dispatch.count).to eq(AEMO::Market.current_dispatch(@nsw.identifier).count)
      end
      it 'should return current trading data' do
        expect(@nsw.current_trading.count).to eq(AEMO::Market.current_trading(@nsw.identifier).count)
      end
    end
  end
end
