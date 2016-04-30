require 'csv'
require 'time'

#
#
# @author Joel Courtney
# @abstract
# @since 0.2.0
# @attr [DateTime] file_created_at DateTime that the file was created at
# @attr [String] from_participant The originator of the NEM12 file
# @attr [String] to_participant The recipient of the NEM12 file
module AEMO
  module NEM12
    class Header
      # As per AEMO NEM12 Specification
      # http://www.aemo.com.au/Consultations/National-Electricity-Market/Open/~/media/Files/Other/consultations/nem/Meter%20Data%20File%20Format%20Specification%20NEM12_NEM13/MDFF_Specification_NEM12_NEM13_Final_v102_clean.ashx
      RECORD_INDICATOR = 100

      VERSION_HEADER = "NEM12"

      @file_created_at  = nil
      @from_participant = nil
      @to_participant   = nil

      attr_accessor :file_created_at, :from_participant, :to_participant

      # Creates an instance of a NEM12 Header
      #
      # @param [DateTime] file_created_at
      # @param [String] from_participant
      # @param [String] to_participant
      # @return [AEMO::NEM12::Header]
      def initialize(file_created_at,from_participant,to_participant)
        raise ArgumentError, "Invalid file_created_at" unless file_created_at.is_a?(DateTime)
        raise ArgumentError, "Invalid from_participant" unless from_participant.is_a?(String)
        raise ArgumentError, "Invalid to_participant" unless to_participant.is_a?(String)

        @file_created_at  = file_created_at
        @from_participant = from_participant
        @to_participant   = to_participant
      end

      # Provides a helper to create the NEM12::Header from a CSV (as per NEM12 specification)
      #
      # @param [String] csv_string The CSV String in format
      def self.parse_csv(csv_string)
        raise ArgumentError, "CSV string is not a string" unless csv_string.is_a?(String)
        raise ArgumentError, "CSV string '#{csv_string}' does not meet specification" unless csv_string.match(/^100,NEM12,\d{12},[A-Z0-9]{1,10},[A-Z0-9]{1,10}$/i)
        data = CSV.parse_line(csv_string)
        AEMO::NEM12::Header.new(DateTime.parse("#{data[2]}00+1000"),data[3],data[4])
      end

      # Helper method to recreate a NEM12 File
      #
      # @return [String]
      def to_nem12
        ['100','NEM12',@file_created_at.strftime("%Y%m%d%H%M"),@from_participant,@to_participant].join(',')
      end
    end
  end
end
