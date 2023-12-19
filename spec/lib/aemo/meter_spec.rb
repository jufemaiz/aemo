# frozen_string_literal: true

require 'spec_helper'

describe AEMO::Meter do
  describe 'instance methods' do
    it 'creates a new instance' do
      expect(described_class.new).to be_a described_class
    end

    it 'can be initialized from MSATS mumbo jumbo' do
      AEMO::MSATS.authorize('ER', 'ER', 'ER')
      nmi_detail_query = AEMO::MSATS.nmi_detail('4001234567')
      meter = nmi_detail_query['MeterRegister']['Meter'].first
      expect(described_class.from_hash(meter)).to be_a described_class
    end
  end
end
