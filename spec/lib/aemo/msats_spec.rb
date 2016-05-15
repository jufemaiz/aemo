require 'spec_helper'

describe AEMO::MSATS do
  describe 'instance methods' do
    it 'creates a new instance' do
      expect(AEMO::MSATS.new.class).to eq(AEMO::MSATS)
    end
  end

  describe 'class methods' do
    describe 'nmi details' do
      before(:each) do
        AEMO::MSATS.authorize('ER', 'ER', 'ER')
      end

      it 'should get data for a valid nmi' do
        nmi_detail_query = AEMO::MSATS.nmi_detail('4001234567')
        expect(nmi_detail_query.class).to eq(Hash)
      end
      it 'should get a 404 for a nonexistent nmi' do
        # nmi_detail_query = AEMO::MSATS.nmi_detail('4001234566')
        # TODO workout what the different errors are here...
      end
      it 'should raise an error for a bad nmi' do
        expect { AEMO::MSATS.nmi_detail('BOBISAFISH') }.to raise_error(ArgumentError)
      end
    end

    describe '#c4' do
      before(:each) do
        AEMO::MSATS.authorize('ER', 'ER', 'ER')
      end

      it 'should return a hash of information' do
        AEMO::MSATS.c4('4001234567', DateTime.now, DateTime.now, DateTime.now)
      end
      it 'should raise an error for a bad nmi' do
        expect { AEMO::MSATS.c4('BOBISAFISH') }.to raise_error(ArgumentError)
      end
      it 'should return a hash of information' do
        # AEMO::MSATS.c4('4001234566', DateTime.now, DateTime.now, DateTime.now)
        # TODO workout what the different errors are here...
      end
    end

    describe '#msats_limits' do
      before(:each) do
        AEMO::MSATS.authorize('ER', 'ER', 'ER')
      end

      it 'should give details of msats_limits' do
        expect(AEMO::MSATS.msats_limits.class).to eq(Hash)
      end
    end

    describe '#nmi_discovery_by_*' do
      before(:each) do
        AEMO::MSATS.authorize('ER', 'ER', 'ER')
      end
      it 'should find by address' do
        expect(AEMO::MSATS.nmi_discovery_by_address('NSW', house_number: 6, street_name: 'Macquarie', suburb_or_place_or_locality: 'Sydney', postcode: 2000).class).to eq(Array)
      end
      it 'should find by meter_serial_number' do
        expect(AEMO::MSATS.nmi_discovery_by_meter_serial_number('NSW', 666).class).to eq(Array)
      end
      it 'should find by meter_serial_number' do
        expect { AEMO::MSATS.nmi_discovery_by_delivery_point_identifier('NSW', 666) }.to raise_error(ArgumentError)
      end
      it 'should find by meter_serial_number' do
        expect(AEMO::MSATS.nmi_discovery_by_delivery_point_identifier('NSW', 10_000_001).class).to eq(Array)
      end
    end

    describe '#system_status' do
      before(:each) do
        AEMO::MSATS.authorize('ER', 'ER', 'ER')
      end
      it 'should provide a status' do
        AEMO::MSATS.system_status
      end
    end
  end
end
