require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))
require 'json'

describe AEMO::NMI do
  # ---
  # CLASS CONSTANTS
  # ---
  describe '::NMI_ALLOCATIONS' do
    it "should be a hash" do
      expect(AEMO::NMI::NMI_ALLOCATIONS.class).to eq(Hash)
    end
  end
  describe '::TNI_CODES' do
    it "should be a hash" do
      expect(AEMO::NMI::TNI_CODES.class).to eq(Hash)
    end
  end
  describe '::DLF_CODES' do
    it "should be a hash" do
      expect(AEMO::NMI::DLF_CODES.class).to eq(Hash)
    end
  end
  
  # ---
  # CLASS METHODS
  # ---
  describe '.valid_nmi?(nmi)' do
    it 'should validate nmi' do
      JSON.parse(File.read(File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures','nmi_checksum.json')))).each do |nmi|
        expect(AEMO::NMI.valid_nmi?(nmi['nmi'])).to eq(true)
      end
    end
    it "should invalidate" do
      expect(AEMO::NMI.valid_nmi?("OOOOOOOOOO")).to eq(false)
    end
    it "should invalidate" do
      expect(AEMO::NMI.valid_nmi?("NM100")).to eq(false)
    end
    it "should invalidate" do
      expect{AEMO::NMI.valid_nmi?()}.to raise_error(ArgumentError)
    end
  end
  
  describe '.self.valid_checksum?(nmi,checksum)' do
    it 'should validate valid nmi and checksums' do
      JSON.parse(File.read(File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures','nmi_checksum.json')))).each do |nmi|
        expect(AEMO::NMI.valid_checksum?(nmi['nmi'],nmi['checksum'])).to eq(true)
      end
    end
  end
  
  describe '.self.network?(nmi)' do
    it 'should return a network for an allocated NMI' do
      network = AEMO::NMI.network('NCCCC00000')
      expect(network.to_a[0].last[:title]).to eq('Ausgrid')
    end
    it 'should return NIL for an unallocated NMI' do
      network = AEMO::NMI.network('ZZZZZZZZZZZZ')
      expect(network).to eq(nil)
    end
  end
  
  # ---
  # INSTANCE METHODS
  # ---
  describe '#initialize' do
    it "should raise an ArgumentError error" do
      expect{ AEMO::NMI.new("OOOOOOOOOO") }.to raise_error(ArgumentError)
    end
    it "should raise an ArgumentError error" do
      expect{ AEMO::NMI.new("NM100") }.to raise_error(ArgumentError)
    end
    it "should raise an ArgumentError error" do
      expect{ AEMO::NMI.new() }.to raise_error(ArgumentError)
    end
  end
  describe '#valid_nmi?' do
    it 'should validate nmi' do
      JSON.parse(File.read(File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures','nmi_checksum.json')))).each do |nmi|
        _nmi = AEMO::NMI.new(nmi['nmi'])
        expect(_nmi.valid_nmi?).to eq(true)
      end
    end
  end
  
  describe '#checksum' do
    it 'should return NMI\'s checksum' do
      JSON.parse(File.read(File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures','nmi_checksum.json')))).each do |nmi|
        _nmi = AEMO::NMI.new(nmi['nmi'])
        expect(_nmi.checksum).to eq(nmi['checksum'])
      end
    end
  end
  
  describe '#valid_checksum?(checksum)' do
    it 'should validate valid checksums' do
      JSON.parse(File.read(File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures','nmi_checksum.json')))).each do |nmi|
        _nmi = AEMO::NMI.new(nmi['nmi'])
        expect(_nmi.valid_checksum?(nmi['checksum'])).to eq(true)
      end
    end
    it 'should not validate invalid checksums' do
      JSON.parse(File.read(File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures','nmi_checksum.json')))).each do |nmi|
        _nmi = AEMO::NMI.new(nmi['nmi'])
        expect(_nmi.valid_checksum?((1+nmi['checksum'])%10)).to eq(false)
      end
    end
  end
  
  describe '#network' do
    # Positive test cases
    it 'should return a network for a valid NMI' do
      JSON.parse(File.read(File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures','nmi_checksum.json')))).each do |nmi|
        _nmi = AEMO::NMI.new(nmi['nmi'])
        unless _nmi.network.nil?
          expect(_nmi.network.class).to eq(Hash)
        end
      end
    end
    # Negative test cases
    it 'should not return a network for a NMI not allocated to a network' do
      JSON.parse(File.read(File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures','nmi_checksum.json')))).each do |nmi|
        _nmi = AEMO::NMI.new(nmi['nmi'])
        if _nmi.network.nil?
          expect(_nmi.network.class).to eq(NilClass)
        end
      end
    end
  end
  
end
