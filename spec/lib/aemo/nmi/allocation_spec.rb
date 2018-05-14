# frozen_string_literal: true

require 'spec_helper'

describe AEMO::NMI::Allocation do
  # ---
  # CLASS METHODS
  # ---
  describe '.all' do
    it 'should return an array of all the Allocations' do
      expect(AEMO::NMI::Allocation.all).to be_a Array
      expect(AEMO::NMI::Allocation.all.first).to be_a AEMO::NMI::Allocation
    end
  end

  describe '.each' do
    it 'should return an enumerable of all the Allocations' do
      expect(AEMO::NMI::Allocation.each).to be_a Enumerable
    end
  end

  describe '.first' do
    it 'should return the first Allocation' do
      expect(AEMO::NMI::Allocation.first).to be_a AEMO::NMI::Allocation
    end
  end

  # ---
  # INSTANCE METHODS
  # ---
  describe '#initialize' do
    context 'valid' do
      it 'should return an Allocation' do
        expect(AEMO::NMI::Allocation.new('My great LNSP', :electricity)).to be_a AEMO::NMI::Allocation
        expect(AEMO::NMI::Allocation.new('My great LNSP', 'electricity')).to be_a AEMO::NMI::Allocation
        expect(AEMO::NMI::Allocation.new('My great gas LNSP', :gas)).to be_a AEMO::NMI::Allocation
        expect(AEMO::NMI::Allocation.new('My great gas LNSP', 'gas')).to be_a AEMO::NMI::Allocation
      end
    end
    context 'invalid' do
      it 'should raise an InvalidNMIAllocationType error' do
        expect { AEMO::NMI::Allocation.new('My terrible LNSP', :water) }.to raise_error AEMO::InvalidNMIAllocationType
        expect { AEMO::NMI::Allocation.new('My terrible LNSP', :broccoli) }.to raise_error AEMO::InvalidNMIAllocationType
        expect { AEMO::NMI::Allocation.new('My terrible LNSP', 'Ch4') }.to raise_error AEMO::InvalidNMIAllocationType
        expect { AEMO::NMI::Allocation.new('My terrible LNSP', 'Natural gas') }.to raise_error AEMO::InvalidNMIAllocationType
        expect { AEMO::NMI::Allocation.new('My terrible LNSP', :coal) }.to raise_error AEMO::InvalidNMIAllocationType
      end
    end
  end
end
