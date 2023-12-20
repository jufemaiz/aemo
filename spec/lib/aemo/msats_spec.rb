# frozen_string_literal: true

require 'spec_helper'

describe AEMO::MSATS do
  describe 'instance methods' do
    it 'creates a new instance' do
      expect(described_class.new.class).to eq(described_class)
    end
  end

  describe 'class methods' do
    describe 'nmi details' do
      describe 'valid MSATS user' do
        before do
          described_class.authorize('ER', 'ER', 'ER')
        end

        it 'gets data for a valid nmi' do
          nmi_detail_query = described_class.nmi_detail('4001234567')
          expect(nmi_detail_query.class).to eq(Hash)
        end

        it 'gets a 404 for a nonexistent nmi' do
          # nmi_detail_query = AEMO::MSATS.nmi_detail('4001234566')
          # TODO workout what the different errors are here...
        end

        it 'raises an error for a bad nmi' do
          expect { described_class.nmi_detail('BOBISAFISH') }.to raise_error(ArgumentError)
        end
      end

      describe 'invalid MSATS user' do
        before do
          described_class.authorize('NOTER', 'NOTER', 'NOTER')
        end

        it 'gets data for a valid nmi' do
          nmi_detail_query = described_class.nmi_detail('4001234567')
          expect(nmi_detail_query.class).to eq(HTTParty::Response)
        end
      end
    end

    describe '#c4' do
      describe 'valid MSATS account' do
        before do
          described_class.authorize('ER', 'ER', 'ER')
        end

        it 'returns a hash of information' do
          expect(described_class.c4('4001234567', Time.now, Time.now, Time.now)).to be_a(Hash)
        end

        it 'raises an error for a bad nmi' do
          expect { described_class.c4('BOBISAFISH') }.to raise_error(ArgumentError)
        end
      end

      describe 'invalid MSATS account' do
        before do
          described_class.authorize('NOTER', 'NOTER', 'NOTER')
        end

        it 'returns response' do
          expect(described_class.c4(
            '4001234567',
            Time.now,
            Time.now,
            Time.now
          ).class).to eq(HTTParty::Response)
        end
      end
    end

    describe '#msats_limits' do
      describe 'valid MSATS user' do
        before do
          described_class.authorize('ER', 'ER', 'ER')
        end

        it 'gives details of msats_limits' do
          expect(described_class.msats_limits.class).to eq(Hash)
        end
      end

      describe 'invalid MSATS user' do
        before do
          described_class.authorize('NOTER', 'NOTER', 'NOTER')
        end

        it 'does not give details of msats_limits' do
          expect(described_class.msats_limits.class).to eq(HTTParty::Response)
        end
      end
    end

    describe '#nmi_discovery_by_*' do
      describe 'valid MSATS user' do
        before do
          described_class.authorize('ER', 'ER', 'ER')
        end

        it 'finds by address' do
          expect(described_class.nmi_discovery_by_address('NSW', house_number: 6, street_name: 'Macquarie',
                                                                 suburb_or_place_or_locality: 'Sydney', postcode: 2000).class).to eq(Array)
        end

        it 'finds by meter_serial_number' do
          expect(described_class.nmi_discovery_by_meter_serial_number('NSW', 666).class).to eq(Array)
        end

        it 'finds by meter_serial_number' do
          expect { described_class.nmi_discovery_by_delivery_point_identifier('NSW', 666) }.to raise_error(ArgumentError)
        end

        it 'finds by meter_serial_number' do
          expect(described_class.nmi_discovery_by_delivery_point_identifier('NSW', 10_000_001).class).to eq(Array)
        end
      end

      describe 'invalid MSATS user' do
        before do
          described_class.authorize('NOTER', 'NOTER', 'NOTER')
        end

        it 'finds by address' do
          expect(described_class.nmi_discovery_by_address('NSW', house_number: 6, street_name: 'Macquarie',
                                                                 suburb_or_place_or_locality: 'Sydney', postcode: 2000).class).to eq(HTTParty::Response)
        end

        it 'finds by meter_serial_number' do
          expect(described_class.nmi_discovery_by_meter_serial_number('NSW', 666).class).to eq(HTTParty::Response)
        end

        it 'finds by meter_serial_number' do
          expect(described_class.nmi_discovery_by_delivery_point_identifier('NSW',
                                                                            10_000_001).class).to eq(HTTParty::Response)
        end
      end
    end

    describe '#system_status' do
      describe 'valid MSATS user' do
        before do
          described_class.authorize('ER', 'ER', 'ER')
        end

        it 'provides a status' do
          described_class.system_status
        end
      end

      describe 'invalid MSATS user' do
        before do
          described_class.authorize('NOTER', 'NOTER', 'NOTER')
        end

        it 'provides a status' do
          expect(described_class.system_status.class).to eq(HTTParty::Response)
        end
      end
    end
  end
end
