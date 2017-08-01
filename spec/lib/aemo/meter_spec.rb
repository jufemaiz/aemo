# frozen_string_literal: true

require 'spec_helper'

describe AEMO::Meter do
  describe 'instance methods' do
    it 'creates a new instance' do
      expect(AEMO::Meter.new).to be_a AEMO::Meter
    end

    it 'can be initialized from MSATS mumbo jumbo' do
      AEMO::MSATS.authorize('ER', 'ER', 'ER')
      nmi_detail_query = AEMO::MSATS.nmi_detail('4001234567')
      meter = nmi_detail_query.dig('MeterRegister', 'Meter').first
      expect(AEMO::Meter.from_hash(meter)).to be_a AEMO::Meter
    end
  end
end
