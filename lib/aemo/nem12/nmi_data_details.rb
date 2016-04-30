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
    class NMIDataDetails
      # As per AEMO NEM12 Specification
      # http://www.aemo.com.au/Consultations/National-Electricity-Market/Open/~/media/Files/Other/consultations/nem/Meter%20Data%20File%20Format%20Specification%20NEM12_NEM13/MDFF_Specification_NEM12_NEM13_Final_v102_clean.ashx
      RECORD_INDICATOR = 200

      # Attributes
      @header   = nil
      @nmi      = nil
      # @todo Move this to AEMO::NMI
      @nmi_configuration = nil # This holds all the registers
      @next_scheduled_read_date = nil
      # @todo Move this to AEMO::NMI::Meter
      @meter_serial_number = nil
      # @todo AEMO::NMI::Register - interval data and events to be children of the register of the meter?.
      @register_id = nil
      @nmi_suffix = nil
      @mdm_data_streaming_identifier = nil
      @unit_of_measurement = nil
      @interval_length = nil

      # Atttribute Capabilities
      attr_accessor :nmi, :nmi_configuration, :register_id, :nmi_suffix, :mdm_data_streaming_identifier, :meter_serial_number, :unit_of_measurement, :interval_length, :next_scheduled_read_date

      # Creates an instance of a NEM12 Header
      #
      # @param [String,AEMO::NMI] nmi
      # @param [Hash] options
      # @return [AEMO::NEM12::NMIDataDetails]
      def initialize(nmi,options={})
        @nmi = AEMO::NMI.new(nmi, options.slice(:nmi_configuration,:next_scheduled_read_date,:meter_serial_number,:register_id,:nmi_suffix,:mdm_data_streaming_identifier,:unit_of_measurement,:interval_length))

        unless options[:register_id].nil?
        end
        unless options[:suffix].nil?
        end
        unless options[:mdm_data_streaming_identifier].nil?
        end
        unless options[:meter_serial_number].nil?
        end
        unless options[:unit_of_measurement].nil?
        end
        unless options[:interval_length].nil?
        end
        unless options[:next_scheduled_read_date].nil?
        end
      end

      # Provides a helper to create the NEM12::Header from a CSV (as per NEM12 specification)
      #
      # @param [String] csv_string The CSV String in format
      def self.parse_csv(csv_string)
        raise ArgumentError, "CSV string is not a string" unless csv_string.is_a?(String)
        raise ArgumentError, "CSV string '#{csv_string}' does not meet specification" unless csv_string.match(/^(200),([A-Z0-9]{10}),([A-HJ-MP-WYZ0-9]{1,240}),([A-HJ-MP-WYZ0-9]{0,10}),([A-HJ-MP-WYZ]\d+),(N\d+),([A-Z0-9]{1,12})?,([A-Z]{1,5}),(1|5|10|15|30),(\d{8})?$/i)
        data = CSV.parse_line(csv_string)
        options = {

        }
        AEMO::NEM12::NMIDataDetails.new(DateTime.parse("#{data[2]}00+1000"),data[3],data[4])
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
