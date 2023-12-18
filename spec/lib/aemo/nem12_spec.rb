# frozen_string_literal: true

require 'spec_helper'
require 'json'

describe AEMO::NEM12 do
  let(:json) { JSON.parse(fixture('nmi_checksum.json').read) }

  describe '#parse_nem12' do
    it 'should reject an empty NEM12 string' do
      expect(AEMO::NEM12.parse_nem12('')).to eq([])
    end
  end

  describe '.parse_nem12_file' do
    it 'should parse a file' do
      Dir.entries(File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'NEM12')).reject { |f| %w[. .. .DS_Store].include?(f) }.each do |file|
        expect(AEMO::NEM12.parse_nem12_file(fixture(File.join('NEM12', file))).length).not_to eq(0)
      end
    end
  end

  describe '.parse_nem12_100' do
    it 'should raise datetime error' do
      expect { AEMO::NEM12.parse_nem12_100('100,NEM12,666,CNRGYMDP,NEMMCO') }.to raise_error(ArgumentError)
    end
    it 'should raise datetime error' do
      expect { AEMO::NEM12.parse_nem12_100('100,NEM12,666,CNRGYMDP,NEMMCO', strict: true) }.to raise_error(ArgumentError)
    end
    it 'should not raise an error' do
      expect { AEMO::NEM12.parse_nem12_100('100,NEM12,201603010000,CNRGYMDP,NEMMCO', strict: true) }.not_to raise_error
    end
  end

  describe '::RECORD_INDICATORS' do
    it 'should be a hash' do
      expect(AEMO::NEM12::RECORD_INDICATORS.class).to eq(Hash)
    end
  end

  describe '#nmi_identifier' do
    it 'returns the NMI identifier or nil' do
      Dir.entries(File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'NEM12'))
         .reject { |f| %w[. .. .DS_Store].include?(f) }
         .each do |file|
        AEMO::NEM12.parse_nem12_file(fixture(File.join('NEM12', file))).each do |nem12|
          expect(nem12.nmi_identifier).to be_a String
        end
      end
    end
  end

  describe '#parse_nem12_200' do
    context 'non-strict mode' do
      it 'should not raise validation warning with bad NMI configuration' do
        expect(AEMO::NEM12.parse_nem12_file(fixture(File.join('NEM12-Errors', 'NEM12#DerpyNMIConfig#CNRGYMDP#NEMMCO.csv')), false))
          .to be_truthy
      end
    end

    context 'strict mode (default)' do
      it 'should raise validation warning with bad NMI configuration' do
        expect { AEMO::NEM12.parse_nem12_file(fixture(File.join('NEM12-Errors', 'NEM12#DerpyNMIConfig#CNRGYMDP#NEMMCO.csv'))) }
          .to raise_error(ArgumentError, 'NMIConfiguration is not valid')
      end
    end
  end

  describe '#parse_nem12_300' do
    it 'should raise invalid record length error' do
      bad_file = fixture(File.join('NEM12-Errors', 'NEM12#InvalidIntervalDataLength#CNRGYMDP#NEMMCO.csv'))
      expect { AEMO::NEM12.parse_nem12_file(bad_file) }.to raise_error(TypeError, 'Invalid record length')
    end

    it 'should raise argument error on 300 empty cells' do
      nem12_empty_cells_300_record = fixture(File.join('NEM12-Errors', 'NEM12#EmptyCells300Record#CNRGYMDP#NEMMCO.csv'))
      expect { AEMO::NEM12.parse_nem12_file(nem12_empty_cells_300_record) }.to raise_error(ArgumentError)
    end
  end

  describe '#parse_nem12_400' do
    it 'should raise argument error on 400 empty cells' do
      nem12_empty_cells_400_record = fixture(File.join('NEM12-Errors', 'NEM12#EmptyCells400Record#CNRGYMDP#NEMMCO.csv'))
      expect { AEMO::NEM12.parse_nem12_file(nem12_empty_cells_400_record) }.to raise_error(ArgumentError)
    end
  end

  describe '#parse_nem12_500' do
  end

  describe '#parse_nem12_900' do
  end

  describe '#flag_to_s' do
    it 'converts the flags to a string' do
      flag = { quality_flag: 'S', method_flag: 11, reason_code: 53 }
      nem12 = AEMO::NEM12.new('NEEE000010')
      expect(nem12.flag_to_s(flag))
        .to eq 'Substituted Data - Check - Bees/Wasp In Meter Box'
    end
  end

  describe '#to_nem12_csv' do
    let(:nem12_filepath) do
      File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'NEM12', 'NEM12#000000000000004#CNRGYMDP#NEMMCO.csv')
    end
    let(:nem12) { described_class.parse_nem12_file(nem12_filepath).first }
    let(:expected) do
"100,NEM12,200505121137,CNRGYMDP,NEMMCO\r
200,NEM1204062,E1,E1,E1,N1,04062,KWH,30,20050503\r
300,20040527,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.735,0.625,0.618,0.63,0.893,1.075,1.263,1.505,1.645,1.073,0.938,1.15,0.75,1.35,1.093,0.973,1.018,0.735,0.718,0.735,0.64,0.638,0.65,0.645,0.73,0.63,0.673,0.688,0.663,0.625,0.628,0.628,0.633,0.645,0.625,0.62,0.623,0.78,V,,,20040609153903,\r
400,1,10,F52,71,\r
400,11,48,E52,,\r
900\r
"
    end

    it 'returns a correct NEM12 file' do
      expect(nem12.to_nem12_csv).to eq(expected)
    end
  end
end
