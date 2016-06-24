require 'spec_helper'

describe AEMO::Market::Interval do
  describe 'AEMO::Market::Interval contstants' do
    it 'has INTERVALS' do
      expect(AEMO::Market::Interval::INTERVALS)
        .to eq(trading: 'Trading', dispatch: 'Dispatch')
    end
  end
  describe 'AEMO::Market::Interval instance methods' do
    it 'creates a valid interval' do
      time = Time.parse('2016-03-01T00:30:00+1000')
      opts = { region: 'NSW1', total_demand: 1000.23, rrp: 76.54,
               period_type: 'TRADING' }
      expect { AEMO::Market::Interval.new(time, opts) }.not_to raise_error
    end

    it 'parses json' do
      json_string = { datetime: Time.parse('2016-03-01T00:30:00+1000'),
                      region: 'NSW1', total_demand: 1000.23, rrp: 76.54,
                      period_type: 'TRADING' }.to_json
      expect(AEMO::Market::Interval.parse_json(json_string)
             .class).to eq AEMO::Market::Interval
    end

    it 'parses csv' do
      csv_row = CSV::Row.new(
        %w(SETTLEMENTDATE REGION TOTALDEMAND RRP PERIODTYPE),
        ['2016-03-01T00:30:00', 'NSW1', 1000.23, 76.54, 'TRADING']
      )
      expect(AEMO::Market::Interval.parse_csv(csv_row).class)
        .to eq AEMO::Market::Interval
    end

    context 'trading intervals' do
      before(:each) do
        @interval = AEMO::Market::Interval.parse_csv(
          CSV::Row.new(
            %w(SETTLEMENTDATE REGION TOTALDEMAND RRP PERIODTYPE),
            ['2016-03-01T00:30:00', 'NSW1', 1000.23, 76.54, 'TRADING']
          )
        )
      end
      it 'has a trailing datetime' do
        expect(@interval.datetime.in_time_zone)
          .to eq(DateTime.parse('2016-03-01T00:30:00+1000'))
      end
      it 'has a leading datetime' do
        expect(@interval.datetime(false).in_time_zone)
          .to eq(DateTime.parse('2016-03-01T00:00:00+1000'))
      end
      it 'has an interval length' do
        expect(@interval.interval_length).to eq(Time.at(1800))
      end
      it 'is a trading interval' do
        expect(@interval.interval_type).to eq(:trading)
      end
      it 'is a trading interval' do
        expect(@interval.trading?).to eq(true)
        expect(@interval.dispatch?).to eq(false)
      end
    end
    context 'dispatch intervals' do
      before(:each) do
        @interval = AEMO::Market::Interval.parse_csv(
          CSV::Row.new(
            %w(SETTLEMENTDATE REGION TOTALDEMAND RRP PERIODTYPE),
            ['2016-03-01T00:30:00', 'NSW1', 1000.23, 76.54, '']
          )
        )
      end
      it 'has a leading datetime for dispatch' do
        expect(@interval.datetime(false))
          .to eq(Time.parse('2016-03-01T00:25:00+1000'))
      end
      it 'has an interval length' do
        expect(@interval.interval_length).to eq(Time.at(300))
      end
      it 'is a dispatch interval' do
        expect(@interval.interval_type).to eq(:dispatch)
      end
      it 'is a dispatch interval' do
        expect(@interval.trading?).to eq(false)
        expect(@interval.dispatch?).to eq(true)
      end
      it 'has a valid value' do
        my_value = (@interval.total_demand * @interval.rrp).round(2)
        expect(@interval.value).to eq(my_value)
      end
    end
  end
end
