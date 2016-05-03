require 'spec_helper'

describe AEMO::Market do
  # it 'returns the SupportedFormats constant for subclasses' do
  #   class MyParser < HTTParty::Parser
  #     SupportedFormats.merge!(
  #       {'application/atom+xml' => :atom }
  #     )
  #   end
  #   expect(MyParser.formats).to include('application/atom+xml' => :atom)
  # end

  describe 'Dispatch data' do
    it 'has an array of data' do
      expect(AEMO::Market.current_dispatch('NSW').class).to eq(Array)
    end
  end

  describe 'Trading data' do
    it 'has an array of data' do
      expect(AEMO::Market.current_trading('NSW').class).to eq(Array)
    end
  end
end
