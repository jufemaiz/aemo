# frozen_string_literal: true

require 'spec_helper'

describe AEMO::Market::Interval do
  describe 'AEMO::Market::Interval constants' do
    it 'has INTERVALS' do
      expect(AEMO::Market::Interval::INTERVALS).to eq(trading: 'Trading', dispatch: 'Dispatch')
    end
  end

  describe 'AEMO::Market::Interval instance methods' do
    before do
      @interval = described_class.new('2016-03-01T00:30:00', 'REGION' => 'NSW', 'TOTALDEMAND' => 1000.23,
                                                             'RRP' => 76.54, 'PERIODTYPE' => 'TRADING')
    end

    it 'creates a valid interval' do
      expect do
        described_class.new('2016-03-01T00:30:00', 'REGION' => 'NSW', 'TOTALDEMAND' => 1000.23, 'RRP' => 76.54,
                                                   'PERIODTYPE' => 'TRADING')
      end.not_to raise_error
    end

    it 'has a trailing datetime' do
      expect(@interval.datetime).to eq(Time.parse('2016-03-01T00:30:00+1000'))
    end

    it 'has a leading datetime' do
      expect(@interval.datetime(trailing_edge: false)).to eq(Time.parse('2016-03-01T00:00:00+1000'))
    end

    it 'has a leading datetime for dispatch' do
      @interval = described_class.new('2016-03-01T00:30:00', 'REGION' => 'NSW', 'TOTALDEMAND' => 1000.23,
                                                             'RRP' => 76.54, 'PERIODTYPE' => '')
      expect(@interval.datetime(trailing_edge: false)).to eq(Time.parse('2016-03-01T00:25:00+1000'))
    end

    it 'has an interval length' do
      expect(@interval.interval_length).to eq(Time.at(300))
    end

    it 'is a trading interval' do
      expect(@interval.interval_type).to eq(:trading)
    end

    it 'is a trading interval' do
      expect(@interval.trading?).to be(true)
      expect(@interval.dispatch?).to be(false)
    end

    it 'is a dispatch interval' do
      @interval = described_class.new('2016-03-01T00:30:00', 'REGION' => 'NSW', 'TOTALDEMAND' => 1000.23,
                                                             'RRP' => 76.54, 'PERIODTYPE' => '')
      expect(@interval.interval_type).to eq(:dispatch)
    end

    it 'is a dispatch interval' do
      @interval = described_class.new('2016-03-01T00:30:00', 'REGION' => 'NSW', 'TOTALDEMAND' => 1000.23,
                                                             'RRP' => 76.54, 'PERIODTYPE' => '')
      expect(@interval.trading?).to be(false)
      expect(@interval.dispatch?).to be(true)
    end

    it 'has a valid value' do
      expect(@interval.value).to eq((@interval.total_demand * @interval.rrp).round(2))
    end
  end
end
