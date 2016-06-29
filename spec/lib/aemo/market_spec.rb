require 'spec_helper'

describe AEMO::Market do
  # it 'returns the SupportedFormats constant for subclasses' do
  #   class MyParser < HTTParty::Parser
  #     SupportedFormats.merge!(
  #       {'application/atom+xml' => :atom }
  #     )
  #   end
  #   expect(MyParser.formats).to include('application/atom+xml' => :atom)
  # end

  describe '.current_dispatch' do
    it 'has an array of data' do
      expect(AEMO::Market.current_dispatch('NSW').class).to eq(Array)
    end
  end

  describe '.current_trading' do
    it 'has an array of data' do
      expect(AEMO::Market.current_trading('NSW').class).to eq(Array)
    end
  end

  describe '.historic_trading_by_range' do
    it 'has an array of data' do
      expect(AEMO::Market.historic_trading_by_range('NSW', Date.parse('2015-01-01'), Date.parse('2015-02-28')).class).to eq(Array)
    end
  end

  describe '.historic_trading' do
    it 'has an array of data' do
      expect(AEMO::Market.historic_trading('NSW', 2015, 0o1).class).to eq(Array)
    end
  end
end
