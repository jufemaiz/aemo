# frozen_string_literal: true

require 'spec_helper'
require 'json'

describe AEMO::NMI do
  let(:json) { JSON.parse(fixture('nmi_checksum.json').read) }

  # ---
  # CLASS CONSTANTS
  # ---
  describe '::TNI_CODES' do
    it 'is a hash' do
      expect(AEMO::NMI::TNI_CODES.class).to eq(Hash)
    end
  end

  describe '::DLF_CODES' do
    it 'is a hash' do
      expect(AEMO::NMI::DLF_CODES.class).to eq(Hash)
    end
  end

  # ---
  # CLASS METHODS
  # ---
  describe '.valid_nmi?(nmi)' do
    context 'valid' do
      it 'validates nmi' do
        json.each do |nmi|
          expect(described_class.valid_nmi?(nmi['nmi'])).to be(true)
        end
      end
    end

    context 'invalid' do
      it 'invalidates' do
        expect(described_class.valid_nmi?('OOOOOOOOOO')).to be(false)
      end

      it 'invalidates' do
        expect(described_class.valid_nmi?('NM100')).to be(false)
      end

      it 'invalidates' do
        expect { described_class.valid_nmi? }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.valid_checksum?(nmi, checksum)' do
    it 'validates valid nmi and checksums' do
      json.each do |nmi|
        expect(described_class.valid_checksum?(nmi['nmi'], nmi['checksum'])).to be(true)
      end
    end
  end

  describe '.network(nmi)' do
    it 'returns a network for an allocated NMI' do
      network = described_class.network('NCCCC00000')
      expect(network.title).to eq('Ausgrid')
    end

    it 'returns NIL for an unallocated NMI' do
      network = described_class.network('ZZZZZZZZZZZZ')
      expect(network).to be_nil
    end
  end

  describe '.allocation(nmi)' do
    it 'returns an Allocation for a NMI' do
      allocation = described_class.allocation('NCCCC00000')
      expect(allocation.title).to eq('Ausgrid')
    end

    it 'returns NIL for an unallocated NMI' do
      allocation = described_class.allocation('ZZZZZZZZZZZZ')
      expect(allocation).to be_nil
    end
  end

  # ---
  # INSTANCE METHODS
  # ---
  describe '#initialize' do
    context 'valid' do
      it 'returns a valid NMI' do
        expect(described_class.new('NM10000000')).to be_a(described_class)
      end

      it 'returns a valid NMI with MSATS' do
        expect(described_class.new('NM10000000', msats_detail: {})).to be_a(described_class)
      end
    end

    context 'invalid' do
      it 'raises an ArgumentError error' do
        expect { described_class.new('OOOOOOOOOO') }.to raise_error(ArgumentError)
      end

      it 'raises an ArgumentError error' do
        expect { described_class.new('NM100') }.to raise_error(ArgumentError)
      end

      it 'raises an ArgumentError error' do
        expect { described_class.new }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#valid_nmi?' do
    it 'validates nmi' do
      json.each do |nmi|
        a_nmi = described_class.new(nmi['nmi'])
        expect(a_nmi.valid_nmi?).to be(true)
      end
    end
  end

  describe '#checksum' do
    it 'returns NMI checksum' do
      json.each do |nmi|
        a_nmi = described_class.new(nmi['nmi'])
        expect(a_nmi.checksum).to eq(nmi['checksum'])
      end
    end
  end

  describe '#valid_checksum?(checksum)' do
    it 'validates valid checksums' do
      json.each do |nmi|
        a_nmi = described_class.new(nmi['nmi'])
        expect(a_nmi.valid_checksum?(nmi['checksum'])).to be(true)
      end
    end

    it 'does not validate invalid checksums' do
      json.each do |nmi|
        a_nmi = described_class.new(nmi['nmi'])
        expect(a_nmi.valid_checksum?((1 + nmi['checksum']) % 10)).to be(false)
      end
    end
  end

  describe '#network' do
    # Positive test cases
    it 'returns a network for a valid NMI' do
      json.each do |nmi|
        a_nmi = described_class.new(nmi['nmi'])
        next if a_nmi.network.nil?

        expect(a_nmi.network).to be_a AEMO::NMI::Allocation
        expect(a_nmi.allocation).to be_a AEMO::NMI::Allocation
      end
    end

    # Negative test cases
    it 'does not return a network for a NMI not allocated to a network' do
      json.each do |nmi|
        a_nmi = described_class.new(nmi['nmi'])
        expect(a_nmi.network.class).to eq(NilClass) if a_nmi.network.nil?
      end
    end
  end

  describe '#friendly_address' do
    it 'returns the empty string if the address is not a hash' do
      nmi = described_class.new('4001234567')
      nmi.address = 'An address'
      expect(nmi.friendly_address).to eq('')
    end

    it 'returns a friendly address if the address is a hash' do
      nmi = described_class.new('4001234567')
      nmi.address = { number: '1', street: 'Bob', street_type: 'Street' }
      expect(nmi.friendly_address).to eq('1, Bob, Street')
    end

    it 'returns a friendly address if the address is a nested hash' do
      nmi = described_class.new('4001234567')
      nmi.address = { house: { number: '1', suffix: 'B' }, street: 'Bob', street_type: 'Street' }
      expect(nmi.friendly_address).to eq('1 B, Bob, Street')
    end
  end

  describe '#current_daily_load' do
    it 'returns zero for no data' do
      @nmi = described_class.new('4001234567')
      expect(@nmi.current_daily_load).to eq(0)
    end
  end

  describe '#current_annual_load' do
    it 'returns zero for no data' do
      @nmi = described_class.new('4001234567')
      expect(@nmi.current_annual_load).to eq(0)
    end
  end

  describe '#meters_by_status' do
    before do
      @nmi = described_class.new('4001234567')
      @nmi.meters = [Struct::DataStream.new(status: 'C'), Struct::DataStream.new(status: 'R')]
    end

    it 'returns current meters' do
      expect(@nmi.meters_by_status.count).to eq(1)
    end

    it 'returns retired meters' do
      expect(@nmi.meters_by_status('R').count).to eq(1)
    end

    it 'returns zero meters for weird status' do
      expect(@nmi.meters_by_status('TMP').count).to eq(0)
    end
  end

  describe 'distribution loss factors' do
    before do
      @nmi = described_class.new('4001234567')
      @nmi.dlf = 'BL0A'
      @nmi.tni = 'NGN2'
    end

    it 'has a valid DLF Code' do
      expect(@nmi.dlf).to eq('BL0A')
    end

    it 'has a DLF value' do
      Timecop.freeze('2016-06-01T00:00:00+1000') do
        expect(@nmi.dlfc_value.class).to eq(Float)
      end
    end

    it 'has DLF values' do
      Timecop.freeze('2016-06-01T00:00:00+1000') do
        expect(@nmi.dlfc_values.class).to eq(Array)
      end
    end

    it 'has historical values for DLF values' do
      valid_dlfc_values = [
        { datetime: '2003-06-01T00:00:00+1000', value: 1.0713 },
        { datetime: '2004-06-01T00:00:00+1000', value: 1.0913 },
        { datetime: '2005-06-01T00:00:00+1000', value: 1.0933 },
        { datetime: '2006-06-01T00:00:00+1000', value: 1.0933 },
        { datetime: '2007-06-01T00:00:00+1000', value: 1.1053 },
        { datetime: '2008-06-01T00:00:00+1000', value: 1.103 },
        { datetime: '2009-06-01T00:00:00+1000', value: 1.0961 },
        { datetime: '2010-06-01T00:00:00+1000', value: 1.0918 },
        { datetime: '2011-06-01T00:00:00+1000', value: 1.0996 },
        { datetime: '2012-06-01T00:00:00+1000', value: 1.0941 },
        { datetime: '2013-06-01T00:00:00+1000', value: 1.0996 },
        { datetime: '2014-06-01T00:00:00+1000', value: 1.0912 },
        { datetime: '2015-06-01T00:00:00+1000', value: 1.0924 },
        { datetime: '2016-06-01T00:00:00+1000', value: 1.0869 },
        { datetime: '2017-06-01T00:00:00+1000', value: 1.0815 },
        { datetime: '2018-06-01T00:00:00+1000', value: 1.0795 }
      ]

      valid_dlfc_values.each do |t|
        Timecop.freeze(t[:datetime]) do
          expect(@nmi.dlfc_value(Time.now)).to eq t[:value]
        end
      end
    end
  end

  describe 'transmission node identifiers and loss factors' do
    before do
      @nmi = described_class.new('4001234567')
      @nmi.dlf = 'BL0A'
      @nmi.tni = 'NGN2'
    end

    it 'has a valid TNI Code' do
      expect(@nmi.tni).to eq('NGN2')
    end

    it 'has a TNI value' do
      Timecop.freeze('2016-06-01T00:00:00+1000') do
        expect(@nmi.tni_value(Time.now).class).to eq(Float)
      end
    end

    it 'has TNI values' do
      Timecop.freeze('2016-06-01T00:00:00+1000') do
        expect(@nmi.tni_values.class).to eq(Array)
      end
    end

    it 'has historical values for TNI values' do
      valid_tni_values = [
        { datetime: '2014-06-01T00:00:00+1000', value: 1.0383 },
        { datetime: '2015-06-01T00:00:00+1000', value: 1.0571 },
        { datetime: '2016-06-01T00:00:00+1000', value: 1.036 },
        { datetime: '2017-06-01T00:00:00+1000', value: 0.9879 },
        { datetime: '2018-06-01T00:00:00+1000', value: 0.9592 }
      ]

      valid_tni_values.each do |t|
        Timecop.freeze(t[:datetime]) do
          expect(@nmi.tni_value(Time.now)).to eq t[:value]
        end
      end
    end
  end

  describe 'MSATS functions' do
    it 'gets data' do
      AEMO::MSATS.authorize('ER', 'ER', 'ER')
      nmi = described_class.new('4001234567')
      nmi.update_from_msats!
      expect(nmi.msats_detail).not_to be_nil
    end

    it 'returns the hash of raw data' do
      AEMO::MSATS.authorize('ER', 'ER', 'ER')
      nmi = described_class.new('4001234567')
      expect(nmi.raw_msats_nmi_detail.class).to eq(Hash)
    end
  end
end
