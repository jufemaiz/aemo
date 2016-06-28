require 'spec_helper'

describe AEMO::NEM12::Header do
  describe '#parse_csv' do
    it 'successfully parses a valid CSV string' do
      expect(AEMO::NEM12::Header.parse_csv('100,NEM12,201501010000,BOB,ted').class).to eq(AEMO::NEM12::Header)
    end
    it 'raises an error if not a string' do
      expect {AEMO::NEM12::Header.parse_csv(nil)}.to raise_error(ArgumentError)
    end
    it 'raises an error if not a valid CSV string' do
      expect {AEMO::NEM12::Header.parse_csv('100,NEM13,201501010000,BOB,ted')}.to raise_error(ArgumentError)
    end
  end
  describe '#initialize' do
    it 'successfully creates a new AEMO::NEM12::Header with correct data' do
      expect(AEMO::NEM12::Header.new(DateTime.now,'BOB','ted').class).to eq(AEMO::NEM12::Header)
    end
    it 'raises error if file_created_at is not valid' do
      expect {AEMO::NEM12::Header.new(nil,'BOB','ted')}.to raise_error(ArgumentError)
    end
    it 'raises error if from_participant is not valid' do
      expect {AEMO::NEM12::Header.new(DateTime.now,nil,'ted')}.to raise_error(ArgumentError)
    end
    it 'raises error if to_participant is not valid' do
      expect {AEMO::NEM12::Header.new(DateTime.now,"BOB",nil)}.to raise_error(ArgumentError)
    end
  end
  describe '#to_nem12' do
    it 'recreates the incoming data that created the AEMO::NEM12::Header object' do
      csv_string = '100,NEM12,201501010000,BOB,ted'
      nem12_header = AEMO::NEM12::Header.parse_csv('100,NEM12,201501010000,BOB,ted')
      expect(nem12_header.to_nem12).to eq(csv_string)
    end
  end
end
