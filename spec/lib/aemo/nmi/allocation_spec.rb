# frozen_string_literal: true

require 'spec_helper'

describe AEMO::NMI::Allocation do
  # ---
  # CLASS METHODS
  # ---
  describe '.all' do
    it 'returns an array of all the Allocations' do
      expect(described_class.all).to be_a Array
      expect(described_class.all.first).to be_a described_class
    end
  end

  describe '.each' do
    it 'returns an enumerable of all the Allocations' do
      expect(described_class.each).to be_a Enumerable
    end
  end

  describe '.first' do
    it 'returns the first Allocation' do
      expect(described_class.first).to be_a described_class
    end
  end

  # ---
  # INSTANCE METHODS
  # ---
  describe '#initialize' do
    context 'valid' do
      it 'returns an Allocation' do
        expect(described_class.new('My great LNSP', :electricity)).to be_a described_class
        expect(described_class.new('My great LNSP', 'electricity')).to be_a described_class
        expect(described_class.new('My great gas LNSP', :gas)).to be_a described_class
        expect(described_class.new('My great gas LNSP', 'gas')).to be_a described_class
      end
    end

    context 'invalid' do
      it 'raises an InvalidNMIAllocationType error' do
        expect { described_class.new('My terrible LNSP', :water) }.to raise_error AEMO::InvalidNMIAllocationType
        expect do
          described_class.new('My terrible LNSP', :broccoli)
        end.to raise_error AEMO::InvalidNMIAllocationType
        expect { described_class.new('My terrible LNSP', 'Ch4') }.to raise_error AEMO::InvalidNMIAllocationType
        expect do
          described_class.new('My terrible LNSP', 'Natural gas')
        end.to raise_error AEMO::InvalidNMIAllocationType
        expect { described_class.new('My terrible LNSP', :coal) }.to raise_error AEMO::InvalidNMIAllocationType
      end
    end
  end
end
