# frozen_string_literal: true

require 'spec_helper'
require 'json'

describe AEMO::NMI do
  let(:json) { JSON.parse(fixture('nmi_checksum.json').read) }

  # ---
  # CLASS CONSTANTS
  # ---
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

  # ---
  # CLASS METHODS
  # ---
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

  describe '.network(nmi)' do
    it 'should return a network for an allocated NMI' do
      network = AEMO::NMI.network('NCCCC00000')
      expect(network.title).to eq('Ausgrid')
    end
    it 'should return NIL for an unallocated NMI' do
      network = AEMO::NMI.network('ZZZZZZZZZZZZ')
      expect(network).to eq(nil)
    end
  end

  describe '.allocation(nmi)' do
    it 'should return an Allocation for a NMI' do
      allocation = AEMO::NMI.allocation('NCCCC00000')
      expect(allocation.title).to eq('Ausgrid')
    end
    it 'should return NIL for an unallocated NMI' do
      allocation = AEMO::NMI.allocation('ZZZZZZZZZZZZ')
      expect(allocation).to eq(nil)
    end
  end

  # ---
  # INSTANCE METHODS
  # ---
  describe '#initialize' do
    context 'valid' do
      it 'should return a valid NMI' do
        expect(AEMO::NMI.new('NM10000000')).to be_a(AEMO::NMI)
      end
      it 'should return a valid NMI with MSATS' do
        expect(AEMO::NMI.new('NM10000000', msats_detail: {})).to be_a(AEMO::NMI)
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
        next if a_nmi.network.nil?
        expect(a_nmi.network).to be_a AEMO::NMI::Allocation
        expect(a_nmi.allocation).to be_a AEMO::NMI::Allocation
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
    it 'should return a friendly address if the address is a nested hash' do
      nmi = AEMO::NMI.new('4001234567')
      nmi.address = { house: { number: '1', suffix: 'B' }, street: 'Bob', street_type: 'Street' }
      expect(nmi.friendly_address).to eq('1 B, Bob, Street')
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

  describe 'distribution loss factors' do
    before(:each) do
      @nmi = AEMO::NMI.new('4001234567')
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
    before(:each) do
      @nmi = AEMO::NMI.new('4001234567')
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
    it 'should get data' do
      AEMO::MSATS.authorize('ER', 'ER', 'ER')
      nmi = AEMO::NMI.new('4001234567')
      nmi.update_from_msats!
      expect(nmi.msats_detail).to_not eq(nil)
    end
    it 'should return the hash of raw data' do
      AEMO::MSATS.authorize('ER', 'ER', 'ER')
      nmi = AEMO::NMI.new('4001234567')
      expect(nmi.raw_msats_nmi_detail.class).to eq(Hash)
    end
  end
end
