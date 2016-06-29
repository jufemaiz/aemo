require 'spec_helper'

describe AEMO::NMI::Address do
  describe 'Class Methods' do
    describe '.parse_msats_hash' do
      describe 'simple address' do
        before(:each) do
          @address = {
            'StructuredAddress' => {
              'House' => { 'HouseNumber' => '19', 'HouseNumberSuffix' => 'A' },
              'Street' => { 'StreetName' => 'GREENFIELD', 'StreetType' => 'ST' }
            },
            'SuburbOrPlaceOrLocality' => 'BANKSMEADOW',
            'StateOrTerritory' => 'NSW',
            'PostCode' => '2019'
          }
        end
        it 'returns AEMO::NMI::Address' do
          expect(AEMO::NMI::Address.parse_msats_hash(@address)).to be_a(AEMO::NMI::Address)
        end
        it 'correctly parses data' do
          address = AEMO::NMI::Address.parse_msats_hash(@address)
          expect(address.to_s).to eq('19A GREENFIELD ST, BANKSMEADOW NSW 2019')
        end
      end
      describe 'complex address' do
        before(:each) do
          @address = {
            'StructuredAddress' => {
              'BuildingOrPropertyName' => 'ONE CENTRAL PARK - RETAIL BLOC',
              'LocationDescriptor' => 'HL RETAIL',
              'House' => { 'HouseNumber' => '28' },
              'Street' => { 'StreetName' => 'BROADWAY' }
            },
            'SuburbOrPlaceOrLocality' => 'CHIPPENDALE',
            'StateOrTerritory' => 'NSW',
            'PostCode' => '2008'
          }
        end

        it 'returns AEMO::NMI::Address' do
          expect(AEMO::NMI::Address.parse_msats_hash(@address)).to be_a(AEMO::NMI::Address)
        end
        it 'correctly parses data' do
          address = AEMO::NMI::Address.parse_msats_hash(@address)
          expect(address.to_s).to eq('ONE CENTRAL PARK - RETAIL BLOC, HL RETAIL, 28 BROADWAY, CHIPPENDALE NSW 2008')
        end
      end
    end
  end
  describe 'Instance Methods' do
  end
end
