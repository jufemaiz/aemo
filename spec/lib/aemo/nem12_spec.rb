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

  describe '.to_nem12_csv' do
    let(:now) { Time.parse('2023-04-05T06:07:08+10:00') }

    context 'with empty nem12s' do
      let(:nem12s) { [] }
      let(:expected) { ['100,NEM12,202304050607,ENOSI,ENOSI', '900', ''].join("\r\n") }

      before { Timecop.freeze(now) }
      after { Timecop.return }

      it 'returns expected' do
        expect(described_class.to_nem12_csv(nem12s: nem12s)).to eq(expected)
      end
    end

    context 'with non-empty nem12s not containing flags' do
      let(:nem12_filepath) do
        File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'NEM12', 'NEM12#000000000000001#CNRGYMDP#NEMMCO.csv')
      end
      let(:nem12s) { described_class.parse_nem12_file(nem12_filepath) }
      let(:expected) do
        [
          '100,NEM12,202304050607,ENOSI,ENOSI',
          '200,NEM1201002,E1E2,E1,E1,N1,01002,KWH,30,',
          '300,20050315,300.0,266.1,191.55,247.8,288.6,280.8,282.45,206.1,204.75,289.5,390.6,360.15,407.7,432.6,435.0,491.85,600.9,541.95,474.6,565.35,548.55,491.85,593.25,602.4,571.35,450.15,509.4,559.95,522.0,520.95,541.2,538.05,484.8,330.9,329.25,331.65,330.75,333.75,335.25,294.15,185.25,184.8,186.45,256.8,329.7,320.1,316.5,321.15,A,,,20050316004209,',
          '200,NEM1201002,E1E2,E2,E2,N2,01002,KWH,30,',
          '300,20050315,113.1,87.6,33.75,60.6,81.9,79.5,81.15,39.75,25.65,58.8,174.3,197.1,390.6,392.55,394.2,418.5,484.95,407.7,407.7,466.5,455.7,386.85,486.9,489.45,465.15,360.0,387.45,458.7,381.9,424.8,446.25,444.45,383.55,172.65,154.05,164.4,164.25,174.45,170.1,110.1,44.55,44.25,39.9,72.3,109.05,102.45,103.95,103.05,A,,,20050316004209,',
          '200,NEM1201002,E1E2,E1,E1,N1,01002,KWH,30,',
          '300,20050316,321.9,326.4,302.7,298.65,304.5,295.35,309.75,312.3,312.0,338.1,376.95,411.9,546.45,548.25,497.85,528.45,580.8,525.0,435.6,569.4,587.4,577.05,487.35,492.15,588.45,455.55,553.65,515.4,539.7,561.6,540.3,555.6,493.8,349.5,323.7,321.3,322.2,317.55,318.45,324.45,324.6,324.6,321.9,318.75,318.6,317.85,317.1,321.3,A,,,20050317022944,',
          '200,NEM1201002,E1E2,E2,E2,N2,01002,KWH,30,',
          '300,20050316,104.85,103.5,82.95,64.8,72.3,71.4,72.9,80.1,94.5,121.05,185.1,282.9,427.8,427.95,322.8,381.45,464.4,413.4,332.25,442.95,472.8,466.35,401.55,400.2,470.7,352.8,426.3,381.3,435.45,453.75,433.2,453.0,388.35,226.05,148.05,149.55,142.65,115.65,105.75,107.1,109.35,111.45,107.1,104.25,103.05,101.85,103.2,107.55,A,,,20050317022944,',
          '200,NEM1201002,E1E2,E1,E1,N1,01002,KWH,30,',
          '300,20050317,322.35,318.0,302.4,294.45,298.65,296.4,315.15,315.6,326.55,358.2,389.7,397.2,513.15,511.2,520.65,510.3,543.45,549.9,419.85,529.2,527.85,506.1,535.05,538.05,369.6,380.85,555.15,558.6,477.9,334.5,337.2,335.25,339.15,335.55,316.2,312.75,312.6,320.25,320.25,315.75,317.25,315.6,314.7,315.3,315.0,315.75,314.4,315.9,A,,,20050318004032,',
          '200,NEM1201002,E1E2,E2,E2,N2,01002,KWH,30,',
          '300,20050317,104.1,100.8,85.8,70.5,70.95,69.45,53.25,55.65,66.6,106.8,182.1,266.55,408.9,402.15,410.7,414.45,436.2,427.8,325.35,442.2,439.2,432.15,435.3,418.8,283.5,294.0,450.45,455.4,368.4,156.0,160.5,137.55,138.0,134.4,112.35,105.6,103.35,111.75,111.15,107.55,106.5,103.95,102.3,105.75,103.8,97.5,99.75,102.0,A,,,20050318004032,',
          '200,NEM1201002,E1E2,E1,E1,N1,01002,KWH,30,',
          '300,20050318,315.15,313.8,296.55,298.5,295.2,298.95,300.75,322.95,330.45,350.7,345.75,346.95,345.9,348.6,300.15,337.5,336.75,345.9,330.45,327.15,334.8,345.75,335.85,320.1,325.5,325.2,326.4,330.6,332.7,332.25,321.0,316.5,299.85,302.4,301.05,263.85,255.45,142.05,138.3,138.3,136.8,138.3,136.05,135.75,135.75,136.65,136.05,130.8,A,,,20050319004041,',
          '200,NEM1201002,E1E2,E2,E2,N2,01002,KWH,30,',
          '300,20050318,103.05,98.85,81.15,75.6,72.15,73.95,74.55,81.15,89.25,124.2,125.7,128.7,136.8,151.05,177.9,174.45,204.0,210.15,180.15,164.4,187.95,211.95,193.8,122.85,124.8,121.2,129.3,131.25,130.95,130.05,118.05,105.75,77.1,75.9,75.0,51.15,44.4,12.3,12.75,12.15,12.45,11.55,14.4,14.55,15.0,14.7,15.75,21.9,A,,,20050319004041,',          '900',
          ''
        ].join("\r\n")
      end

      before { Timecop.freeze(now) }
      after { Timecop.return }

      it 'returns expected' do
        expect(described_class.to_nem12_csv(nem12s: nem12s)).to eq(expected)
      end
    end

    context 'with non-empty nem12s containing flags' do
      let(:nem12_filepath) do
        File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'NEM12', 'NEM12#000000000000004#CNRGYMDP#NEMMCO.csv')
      end
      let(:nem12s) { described_class.parse_nem12_file(nem12_filepath) }
      let(:expected) do
        [
          '100,NEM12,202304050607,ENOSI,ENOSI',
          '200,NEM1204062,E1,E1,E1,N1,04062,KWH,30,20050503',
          '300,20040527,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.735,0.625,0.618,0.63,0.893,1.075,1.263,1.505,1.645,1.073,0.938,1.15,0.75,1.35,1.093,0.973,1.018,0.735,0.718,0.735,0.64,0.638,0.65,0.645,0.73,0.63,0.673,0.688,0.663,0.625,0.628,0.628,0.633,0.645,0.625,0.62,0.623,0.78,V,,,20040609153903,',
          '400,1,10,F52,71,',
          '400,11,48,E52,,',
          '200,NEM1204062,E1,E1,E1,N1,04062,KWH,30,20050503',
          '300,20040528,0.68,0.653,0.62,0.623,0.618,0.625,0.613,0.623,0.618,0.615,0.613,0.76,0.665,0.638,0.61,0.648,0.65,0.645,0.895,0.668,0.645,0.648,0.655,0.73,0.695,0.67,0.638,0.643,0.64,0.723,0.653,0.645,0.633,0.71,0.683,0.648,0.625,0.63,0.625,0.63,0.638,0.635,0.633,0.638,0.673,0.765,0.65,0.628,V,,,20040609000001,',
          '400,1,48,E52,,',
          '200,NEM1204062,E1,E1,E1,N1,04062,KWH,30,20050503',
          '300,20040529,0.633,0.613,0.628,0.618,0.625,0.623,0.623,0.613,0.655,0.663,0.645,0.708,0.608,0.618,0.63,0.625,0.62,0.635,0.63,0.638,0.693,0.71,0.683,0.645,0.638,0.653,0.653,0.648,0.655,0.745,0.69,0.695,0.68,0.643,0.645,0.635,0.628,0.625,0.635,0.628,0.673,0.688,0.685,0.66,0.638,0.718,0.638,0.63,V,,,20040609000001,',
          '400,1,48,E52,,',
          '900',
          ''
        ].join("\r\n")
      end

      before { Timecop.freeze(now) }
      after { Timecop.return }

      it 'returns expected' do
        expect(described_class.to_nem12_csv(nem12s: nem12s)).to eq(expected)
      end
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
