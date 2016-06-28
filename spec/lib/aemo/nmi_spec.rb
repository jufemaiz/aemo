require 'spec_helper'
require 'json'

describe AEMO::NMI do
  let(:json) { JSON.parse(fixture('nmi_checksum.json').read) }

  describe 'Class Constants' do
    describe '::NMI_ALLOCATIONS' do
      it 'should be a hash' do
        expect(AEMO::NMI::NMI_ALLOCATIONS.class).to eq(Hash)
      end
    end
    describe '::TNI_CODES' do
      it 'should be a hash' do
        expect(AEMO::NMI::TNI_CODES.class).to eq(Hash)
      end
    end
    describe '::DLF_CODES' do
      it 'should be a hash' do
        expect(AEMO::NMI::DLF_CODES.class).to eq(Hash)
      end
    end
  end

  describe 'Class Methods' do
    describe '.valid_nmi?(nmi)' do
      context 'valid' do
        it 'should validate nmi' do
          json.each do |nmi|
            expect(AEMO::NMI.valid_nmi?(nmi['nmi'])).to eq(true)
          end
        end
      end
      context 'invalid' do
        it 'should invalidate' do
          expect(AEMO::NMI.valid_nmi?('OOOOOOOOOO')).to eq(false)
        end
        it 'should invalidate' do
          expect(AEMO::NMI.valid_nmi?('NM100')).to eq(false)
        end
        it 'should invalidate' do
          expect { AEMO::NMI.valid_nmi? }.to raise_error(ArgumentError)
        end
      end
    end

    describe '.valid_checksum?(nmi, checksum)' do
      it 'should validate valid nmi and checksums' do
        json.each do |nmi|
          expect(AEMO::NMI.valid_checksum?(nmi['nmi'], nmi['checksum'])).to eq(true)
        end
      end
    end

    describe '.network?(nmi)' do
      it 'should return a network for an allocated NMI' do
        network = AEMO::NMI.network('NCCCC00000')
        expect(network.to_a[0].last[:title]).to eq('Ausgrid')
      end
      it 'should return NIL for an unallocated NMI' do
        network = AEMO::NMI.network('ZZZZZZZZZZZZ')
        expect(network).to eq(nil)
      end
    end
  end

  describe 'Instance Methods' do
    describe '#initialize' do
      context 'valid' do
        it 'should return a valid NMI' do
          expect(AEMO::NMI.new('NM10000000')).to be_a(AEMO::NMI)
        end
        it 'should return a valid NMI with MSATS' do
          expect(AEMO::NMI.new('NM10000000', msats_detail: {})).to be_a(AEMO::NMI)
        end
        it 'has roles option' do
          expect(AEMO::NMI.new('NM10000000', roles: 'A Role')).to be_a(AEMO::NMI)
        end
        describe 'has nmi_configuration option' do
          it 'E1' do
            expect(AEMO::NMI.new('NM10000000', nmi_configuration: 'E1')).to be_a(AEMO::NMI)
          end
          it 'E1E2' do
            nmi = AEMO::NMI.new('NM10000000', nmi_configuration: 'E1E2')
            expect(nmi.meters.count).to eq(2)
          end
          it 'E1B1Q1K1E2' do
            nmi = AEMO::NMI.new('NM10000000', nmi_configuration: 'E1B1Q1K1E2')
            expect(nmi.meters.count).to eq(2)
          end
        end
        it 'has next_scheduled_read_date option' do
          expect(AEMO::NMI.new('NM10000000', next_scheduled_read_date: Date.parse('2016-06-28'))).to be_a(AEMO::NMI)
        end
        it 'has meter_serial_number option' do
          expect(AEMO::NMI.new('NM10000000', meter_serial_number: 'ABC123')).to be_a(AEMO::NMI)
        end
        it 'has register_id option' do
          expect(AEMO::NMI.new('NM10000000', register_id: '1')).to be_a(AEMO::NMI)
        end
        it 'has nmi_suffix option' do
          expect(AEMO::NMI.new('NM10000000', nmi_suffix: 'E1')).to be_a(AEMO::NMI)
        end
        it 'has mdm_data_streaming_identifier option' do
          expect(AEMO::NMI.new('NM10000000', mdm_data_streaming_identifier: 'N1')).to be_a(AEMO::NMI)
        end
        it 'has unit_of_measurement option' do
          expect(AEMO::NMI.new('NM10000000', unit_of_measurement: 'kWh')).to be_a(AEMO::NMI)
        end
        it 'has interval_length option' do
          expect(AEMO::NMI.new('NM10000000', interval_length: 30)).to be_a(AEMO::NMI)
        end
      end
      context 'invalid' do
        it 'should raise an ArgumentError error' do
          expect { AEMO::NMI.new('OOOOOOOOOO') }.to raise_error(ArgumentError)
        end
        it 'should raise an ArgumentError error' do
          expect { AEMO::NMI.new('NM100') }.to raise_error(ArgumentError)
        end
        it 'should raise an ArgumentError error' do
          expect { AEMO::NMI.new }.to raise_error(ArgumentError)
        end
      end
    end
    describe '#valid_nmi?' do
      it 'should validate nmi' do
        json.each do |nmi|
          a_nmi = AEMO::NMI.new(nmi['nmi'])
          expect(a_nmi.valid_nmi?).to eq(true)
        end
      end
    end

    describe '#checksum' do
      it 'should return NMI\'s checksum' do
        json.each do |nmi|
          a_nmi = AEMO::NMI.new(nmi['nmi'])
          expect(a_nmi.checksum).to eq(nmi['checksum'])
        end
      end
    end

    describe '#valid_checksum?(checksum)' do
      it 'should validate valid checksums' do
        json.each do |nmi|
          a_nmi = AEMO::NMI.new(nmi['nmi'])
          expect(a_nmi.valid_checksum?(nmi['checksum'])).to eq(true)
        end
      end
      it 'should not validate invalid checksums' do
        json.each do |nmi|
          a_nmi = AEMO::NMI.new(nmi['nmi'])
          expect(a_nmi.valid_checksum?((1 + nmi['checksum']) % 10)).to eq(false)
        end
      end
    end

    describe '#network' do
      # Positive test cases
      it 'should return a network for a valid NMI' do
        json.each do |nmi|
          a_nmi = AEMO::NMI.new(nmi['nmi'])
          expect(a_nmi.network.class).to eq(Hash) unless a_nmi.network.nil?
        end
      end
      # Negative test cases
      it 'should not return a network for a NMI not allocated to a network' do
        json.each do |nmi|
          a_nmi = AEMO::NMI.new(nmi['nmi'])
          expect(a_nmi.network.class).to eq(NilClass) if a_nmi.network.nil?
        end
      end
    end

    describe '#friendly_address' do
      it 'should return the empty string if the address is not a hash' do
        nmi = AEMO::NMI.new('4001234567')
        nmi.address = 'An address'
        expect(nmi.friendly_address).to eq('')
      end
      it 'should return a friendly address if the address is a hash' do
        nmi = AEMO::NMI.new('4001234567')
        nmi.address = { number: '1', street: 'Bob', street_type: 'Street' }
        expect(nmi.friendly_address).to eq('1, Bob, Street')
      end
      it 'should return a friendly address if the address is a hash' do
        nmi = AEMO::NMI.new('4001234567')
        nmi.address = { number: '1', street: 'Bob', street_type: 'Street', tmp: { x: 'x', y: 'y' } }
        expect(nmi.friendly_address).to eq('1, Bob, Street, x y')
      end
    end

    describe '#current_daily_load' do
      it 'should return zero for no data' do
        @nmi = AEMO::NMI.new('4001234567')
        expect(@nmi.current_daily_load).to eq(0)
      end
    end

    describe '#current_annual_load' do
      it 'should return zero for no data' do
        @nmi = AEMO::NMI.new('4001234567')
        expect(@nmi.current_annual_load).to eq(0)
      end
    end

    describe '#meters_by_status' do
      before(:each) do
        @nmi = AEMO::NMI.new('4001234567')
        @nmi.meters = [OpenStruct.new(status: 'C'), OpenStruct.new(status: 'R')]
      end
      it 'should return current meters' do
        expect(@nmi.meters_by_status.count).to eq(1)
      end
      it 'should return retired meters' do
        expect(@nmi.meters_by_status('R').count).to eq(1)
      end
      it 'should return zero meters for weird status' do
        expect(@nmi.meters_by_status('TMP').count).to eq(0)
      end
    end

    describe '#data_streams_by_status' do
      before(:each) do
        @nmi = AEMO::NMI.new('4001234567')
        @nmi.data_streams = [OpenStruct.new(status: 'A'), OpenStruct.new(status: 'I')]
      end
      it 'should return active data_streams' do
        expect(@nmi.data_streams_by_status.count).to eq(1)
      end
      it 'should return inactive data_streams' do
        expect(@nmi.data_streams_by_status('I').count).to eq(1)
      end
      it 'should return zero data_streams for weird status' do
        expect(@nmi.data_streams_by_status('TMP').count).to eq(0)
      end
    end

    describe 'distribution loss factors' do
      before(:each) do
        @nmi = AEMO::NMI.new('4001234567')
        @nmi.dlf = 'BL0A'
        @nmi.tni = 'NGN2'
      end

      describe '#dlf' do
        it 'has a valid DLF Code' do
          expect(@nmi.dlf).to eq('BL0A')
        end
      end
      describe '#dlfc_value' do
        it 'has a DLF value' do
          expect(@nmi.dlfc_value.class).to eq(Float)
        end
      end
      describe '#dlfc_values' do
        it 'has a DLF value' do
          expect(@nmi.dlfc_values.class).to eq(Array)
        end
      end
    end

    describe 'transmission node identifiers and loss factors' do
      before(:each) do
        @nmi = AEMO::NMI.new('4001234567')
        @nmi.dlf = 'BL0A'
        @nmi.tni = 'NGN2'
      end
      describe '#tni' do
        it 'has a valid TNI Code' do
          expect(@nmi.tni).to eq('NGN2')
        end
      end
      describe '#tni_value' do
        it 'has a TNI value' do
          expect(@nmi.tni_value.class).to eq(Float)
        end
      end
      describe '#tni_values' do
        it 'has TNI values' do
          puts @nmi.tni_values.inspect
          expect(@nmi.tni_values.class).to eq(Array)
        end
      end
    end

    describe 'MSATS functions' do
      describe '#update_from_msats!' do
        before(:each) do
          AEMO::MSATS.authorize('ER', 'ER', 'ER')
          @nmi = AEMO::NMI.new('4001234567')
          @nmi.update_from_msats!
        end
        it 'should get data' do
          expect(@nmi.msats_detail).to_not eq(nil)
        end

        it 'should return the hash of raw data' do
          expect(@nmi.raw_msats_nmi_detail.class).to eq(Hash)
        end
      end
    end
  end
end
