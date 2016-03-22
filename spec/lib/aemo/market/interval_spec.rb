require 'spec_helper'

describe AEMO::Market::Interval do
  describe 'AEMO::Market::Interval contstants' do
    it 'has INTERVALS' do
      expect(AEMO::Market::Interval::INTERVALS).to eq({trading: 'Trading',dispatch: 'Dispatch'})
    end
  end
  describe 'AEMO::Market::Interval instance methods' do
    before(:each) do
      @interval = AEMO::Market::Interval.new("2016-03-01T00:30:00", {'REGION' => 'NSW', 'TOTALDEMAND' => 1000.23, 'RRP' => 76.54, 'PERIODTYPE' => 'TRADING'})
    end
    it 'creates a valid interval' do
      expect {AEMO::Market::Interval.new("2016-03-01T00:30:00", {'REGION' => 'NSW', 'TOTALDEMAND' => 1000.23, 'RRP' => 76.54, 'PERIODTYPE' => 'TRADING'})}.not_to raise_error
    end
    it 'has a trailing datetime' do
      expect(@interval.datetime).to eq(DateTime.parse("2016-03-01T00:30:00+1000"))
    end
    it 'has a leading datetime' do
      expect(@interval.datetime(false)).to eq(DateTime.parse("2016-03-01T00:00:00+1000"))
    end
    it 'has a leading datetime for dispatch' do
      @interval = AEMO::Market::Interval.new("2016-03-01T00:30:00", {'REGION' => 'NSW', 'TOTALDEMAND' => 1000.23, 'RRP' => 76.54, 'PERIODTYPE' => ''})
      expect(@interval.datetime(false)).to eq(DateTime.parse("2016-03-01T00:25:00+1000"))
    end
    it 'has an interval length' do
      expect(@interval.interval_length).to eq(Time.at(300))
    end
    it 'is a trading interval' do
      expect(@interval.interval_type).to eq(:trading)
    end
    it 'is a trading interval' do
      expect(@interval.is_trading?).to eq(true)
      expect(@interval.is_dispatch?).to eq(false)
    end
    it 'is a dispatch interval' do
      @interval = AEMO::Market::Interval.new("2016-03-01T00:30:00", {'REGION' => 'NSW', 'TOTALDEMAND' => 1000.23, 'RRP' => 76.54, 'PERIODTYPE' => ''})
      expect(@interval.interval_type).to eq(:dispatch)
    end
    it 'is a dispatch interval' do
      @interval = AEMO::Market::Interval.new("2016-03-01T00:30:00", {'REGION' => 'NSW', 'TOTALDEMAND' => 1000.23, 'RRP' => 76.54, 'PERIODTYPE' => ''})
      expect(@interval.is_trading?).to eq(false)
      expect(@interval.is_dispatch?).to eq(true)
    end
    it 'has a valid value' do
      expect(@interval.value).to eq((@interval.total_demand * @interval.rrp).round(2))
    end
  end
end
