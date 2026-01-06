# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AEMO::MeterData::Flag do
  describe '.new' do
    it 'creates a flag with all attributes' do
      flag = described_class.new(quality_flag: 'E', method_flag: 52, reason_code: 1)
      expect(flag.quality_flag).to eq('E')
      expect(flag.method_flag).to eq(52)
      expect(flag.reason_code).to eq(1)
    end

    it 'creates a flag with nil attributes' do
      flag = described_class.new
      expect(flag.quality_flag).to be_nil
      expect(flag.method_flag).to be_nil
      expect(flag.reason_code).to be_nil
    end

    it 'validates quality flag' do
      expect { described_class.new(quality_flag: 'X') }.to raise_error(ArgumentError, /Invalid quality flag/)
    end

    it 'validates method flag' do
      expect { described_class.new(method_flag: 999) }.to raise_error(ArgumentError, /Invalid method flag/)
    end

    it 'validates reason code' do
      expect { described_class.new(reason_code: 999) }.to raise_error(ArgumentError, /Invalid reason code/)
    end

    it 'validates flag combinations' do
      expect { described_class.new(quality_flag: 'E') }.to raise_error(ArgumentError, /requires a method flag/)
    end
  end

  describe '.from_hash' do
    it 'creates a flag from a hash' do
      flag = described_class.from_hash({ quality_flag: 'E', method_flag: 52, reason_code: 1 })
      expect(flag.quality_flag).to eq('E')
      expect(flag.method_flag).to eq(52)
      expect(flag.reason_code).to eq(1)
    end

    it 'returns nil for nil input' do
      expect(described_class.from_hash(nil)).to be_nil
    end

    it 'returns the flag if already a Flag instance' do
      flag = described_class.new(quality_flag: 'A')
      expect(described_class.from_hash(flag)).to eq(flag)
    end
  end

  describe '.normalize' do
    it 'normalizes nil to actual data flag' do
      flag = described_class.normalize(nil)
      expect(flag.quality_flag).to eq('A')
      expect(flag.method_flag).to be_nil
      expect(flag.reason_code).to be_nil
    end

    it 'removes method flag from A quality flag' do
      flag = described_class.normalize({ quality_flag: 'A', method_flag: 52 })
      expect(flag.quality_flag).to eq('A')
      expect(flag.method_flag).to be_nil
    end

    it 'removes method flag and reason code from V quality flag' do
      flag = described_class.normalize({ quality_flag: 'V', method_flag: 52, reason_code: 1 })
      expect(flag.quality_flag).to eq('V')
      expect(flag.method_flag).to be_nil
      expect(flag.reason_code).to be_nil
    end

    it 'preserves E quality flag with method flag' do
      flag = described_class.normalize({ quality_flag: 'E', method_flag: 52 })
      expect(flag.quality_flag).to eq('E')
      expect(flag.method_flag).to eq(52)
    end
  end

  describe '#to_quality_method' do
    it 'returns A for nil quality flag' do
      flag = described_class.new
      expect(flag.to_quality_method).to eq('A')
    end

    it 'returns quality flag when method flag is nil' do
      flag = described_class.new(quality_flag: 'A')
      expect(flag.to_quality_method).to eq('A')
    end

    it 'returns quality flag with formatted method flag' do
      flag = described_class.new(quality_flag: 'E', method_flag: 52)
      expect(flag.to_quality_method).to eq('E52')
    end
  end

  describe '#to_s' do
    it 'returns nil for nil flag' do
      flag = described_class.new
      expect(flag.to_s).to be_nil
    end

    it 'returns quality flag description' do
      flag = described_class.new(quality_flag: 'A')
      expect(flag.to_s).to eq('Actual Data')
    end

    it 'returns quality flag and method flag description' do
      flag = described_class.new(quality_flag: 'E', method_flag: 52)
      expect(flag.to_s).to eq('Forward Estimated Data - Previous Read')
    end

    it 'returns quality flag, method flag, and reason code description' do
      flag = described_class.new(quality_flag: 'E', method_flag: 52, reason_code: 1)
      expect(flag.to_s).to eq('Forward Estimated Data - Previous Read - Meter/Equipment Changed')
    end
  end

  describe '#to_h' do
    it 'returns a hash representation' do
      flag = described_class.new(quality_flag: 'E', method_flag: 52, reason_code: 1)
      expect(flag.to_h).to eq({ quality_flag: 'E', method_flag: 52, reason_code: 1 })
    end
  end

  describe '#==' do
    it 'compares two flags' do
      flag1 = described_class.new(quality_flag: 'E', method_flag: 52, reason_code: 1)
      flag2 = described_class.new(quality_flag: 'E', method_flag: 52, reason_code: 1)
      expect(flag1).to eq(flag2)
    end

    it 'compares flag with hash' do
      flag = described_class.new(quality_flag: 'E', method_flag: 52, reason_code: 1)
      expect(flag).to eq({ quality_flag: 'E', method_flag: 52, reason_code: 1 })
    end
  end
end
