require 'spec_helper'

describe AEMO::NEM12::NMIDataDetails do
  describe 'Class Methods' do
    describe '#parse_csv' do
      it 'successfully parses a valid CSV string' do
        expect(AEMO::NEM12::NMIDataDetails.parse_csv('200,4001000007,B1E1K1Q1,,E1,N1,215085697,kWh,15,').class).to eq(AEMO::NEM12::NMIDataDetails)
      end
      it 'raises an error if not a string' do
        expect { AEMO::NEM12::NMIDataDetails.parse_csv(nil) }.to raise_error(ArgumentError)
      end
      it 'raises an error if not a valid CSV string' do
        csv_string = '300,20160324,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'\
                     '0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'\
                     '0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'\
                     '0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,A,,,20160325015730,'
        expect { AEMO::NEM12::NMIDataDetails.parse_csv(csv_string) }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'Instance Methods' do
    describe '#initialize' do
      it 'successfully creates a new AEMO::NEM12::NMIDataDetails with correct data' do
        expect(AEMO::NEM12::NMIDataDetails.new('4001234567').class).to eq(AEMO::NEM12::NMIDataDetails)
      end

      it 'raises error if file_created_at is not valid' do
        expect { AEMO::NEM12::NMIDataDetails.new(nil) }.to raise_error(ArgumentError)
      end

      describe 'with options' do
        describe 'has nmi_configuration' do
          it do
            expect(AEMO::NEM12::NMIDataDetails.new('4001234567').class).to eq(AEMO::NEM12::NMIDataDetails)
          end
          it 'has a nmi with multiple meters'
        end
      end
    end
  end
end
