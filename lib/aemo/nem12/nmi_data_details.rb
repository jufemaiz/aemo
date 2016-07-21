# encoding: UTF-8
require 'csv'
require 'json'
require 'time'

module AEMO
  class NEM12
    # [AEMO::NEM12::NMIDataDetails]
    #
    # @author Joel Courtney
    # @abstract
    # @since 0.2.0
    # @attr [DateTime] file_created_at DateTime that the file was created at
    # @attr [String] from_participant The originator of the NEM12 file
    # @attr [String] to_participant The recipient of the NEM12 file
    class NMIDataDetails
      # As per AEMO NEM12 Specification
      # http://www.aemo.com.au/Consultations/National-Electricity-Market/Open/~/media/Files/Other/consultations/nem/Meter%20Data%20File%20Format%20Specification%20NEM12_NEM13/MDFF_Specification_NEM12_NEM13_Final_v102_clean.ashx
      RECORD_INDICATOR = 200

      # Attributes
      @header   = nil
      @nmi      = nil
      # @todo Move this to AEMO::NMI
      # This holds all the registers
      @nmi_configuration = nil
      @next_scheduled_read_date = nil
      # @todo Move this to AEMO::NMI::Meter
      @meter_serial_number = nil
      # @todo AEMO::NMI::Register - interval data and events to be children of the register of the meter?.
      @register_id = nil
      @nmi_suffix = nil
      @mdm_data_streaming_identifier = nil
      @unit_of_measurement = nil
      @interval_length = nil
      #
      @interval_data = []

      # Atttribute Capabilities
      attr_accessor :nmi,
                    :nmi_configuration,
                    :register_id,
                    :nmi_suffix,
                    :mdm_data_streaming_identifier,
                    :meter_serial_number,
                    :unit_of_measurement,
                    :interval_length,
                    :next_scheduled_read_date,
                    :interval_data

      class << self
        # Provides a helper to create the NEM12::Header from a CSV (as per NEM12 specification)
        #
        # @param [String] csv_string The CSV String in format
        # @return [AEMO::NEM12::NMIDataDetails]
        def parse_csv(csv_string)
          # Validate
          AEMO.validate_string_pattern(:csv_string, csv_string, /^(200),([A-Z0-9]{10}),([A-HJ-MP-WYZ0-9]{1,240}),([A-HJ-MP-WYZ0-9]{0,10}),([A-HJ-MP-WYZ]\d+),(N\d+),([A-Z0-9]{1,12})?,([A-Z]{1,5}),(1|5|10|15|30),(\d{8})?$/i)
          # Split the data
          data = CSV.parse_line(csv_string)
          # Create the NMIDataDetails object
          nmi = AEMO::NMI.new(data[1], nmi_configuration: data[2])
          options = {
            register_id: data[3],
            suffix: data[4],
            mdm_data_streaming_identifier: data[5],
            meter_serial_number: data[6],
            unit_of_measurement: data[7],
            interval_length: data[8].to_i,
            next_scheduled_read_date: data[9].nil? ? nil : DateTime.parse("#{data[9]}000000+1000")
          }
          AEMO::NEM12::NMIDataDetails.new(nmi, options)
        end
      end

      # Creates an instance of a NEM12 Header
      #
      # @param [String,AEMO::NMI] nmi
      # @param [Hash] options
      # @option options [String] :nmi_configuration
      # @option options [String] :register_id
      # @option options [String] :suffix
      # @option options [String] :mdm_data_streaming_identifier
      # @option options [String] :meter_serial_number
      # @option options [String] :unit_of_measurement
      # @option options [Integer] :interval_length
      # @option options [DateTime] :next_scheduled_read_date
      # @return [AEMO::NEM12::NMIDataDetails]
      def initialize(nmi, options = {})
        raise ArgumentError, "NMI is neither String nor AEMO::NMI but #{nmi.class}" unless [String, AEMO::NMI].include?(nmi.class)

        # Set NMI properly
        @nmi = if nmi.is_a?(String)
                 AEMO::NMI.new(nmi, options.slice(:nmi_configuration, :next_scheduled_read_date))
               elsif nmi.is_a?(AEMO::NMI)
                 nmi
               end

        options = options.slice(:nmi_configuration, :next_scheduled_read_date, :meter_serial_number, :register_id, :suffix, :mdm_data_streaming_identifier, :unit_of_measurement, :interval_length)

        unless options[:nmi_configuration].nil?
          unless options[:nmi_configuration].is_a?(String) && options[:nmi_configuration].split(/([A-Z]\d+)/).reject(&:empty?).join('') == options[:nmi_configuration]
            raise ArgumentError 'nmi_configuration is not valid'
          end
          @nmi_configuration = options[:nmi_configuration]
        end

        unless options[:register_id].nil?
          validate_string_pattern(:register_id, options[:register_id], /^[A-Z]?\d+$/)
          @register_id = options[:register_id]
        end

        unless options[:suffix].nil?
          validate_string_pattern(:suffix, options[:suffix], /^[A-Z]?\d+$/)
          @suffix = options[:suffix]
        end

        unless options[:mdm_data_streaming_identifier].nil?
          validate_string_pattern(:mdm_data_streaming_identifier, options[:mdm_data_streaming_identifier], /^N\d+$/)
          @mdm_data_streaming_identifier = options[:mdm_data_streaming_identifier]
        end

        unless options[:meter_serial_number].nil?
          validate_string_pattern(:meter_serial_number, options[:meter_serial_number], /^.*$/)
          @meter_serial_number = options[:meter_serial_number]
        end

        if options[:unit_of_measurement].is_a?(AEMO::NMI::UnitOfMeasurement)
          @unit_of_measurement = options[:unit_of_measurement]
        elsif !options[:unit_of_measurement].nil?
          unless AEMO::NMI::UnitOfMeasurement.valid?(options[:unit_of_measurement])
            raise ArgumentError 'unit_of_measurement is not valid'
          end
          @unit_of_measurement = options[:unit_of_measurement]
        end

        unless options[:interval_length].nil?
          raise ArgumentError 'interval_length is not valid' unless %w(1 5 10 15 30).include?(options[:interval_length].to_s)
          @interval_length = options[:interval_length]
        end

        unless options[:next_scheduled_read_date].nil?
          raise ArgumentError, "next_scheduled_read_date is neither String nor DateTime but #{nmi.class}" unless [String, DateTime].include?(options[:next_scheduled_read_date].class)
          if options[:next_scheduled_read_date].is_a?(String) && options[:next_scheduled_read_date] =~ /^\d{8}$/
            raise ArgumentError, 'next_scheduled_read_date is not in proper format of YYYYMMDD'
          end
          @next_scheduled_read_date = options[:next_scheduled_read_date]
        end
      end

      # Description of method
      #
      # @param [String] csv_string
      # @return [AEMO::NEM12::Interval::Data]
      def parse_interval_data(csv_string)

      end

      def parse_event_data()

      end


      # Helper method to an array
      #
      # @return [Array]
      def to_a
        [
          @nmi.nmi,
          @nmi_configuration,
          @register_id,
          @suffix,
          @mdm_data_streaming_identifier,
          @meter_serial_number,
          @unit_of_measurement.title,
          @interval_length,
          @next_scheduled_read_date.nil? ? '' : @next_scheduled_read_date.strftime('%Y%m%d')
        ]
      end

      # Helper method to recreate a NEM12 File
      #
      # @return [String]
      def to_nem12
        ([200] + to_a).join(',')
      end

      # Return in Hash format
      #
      # @return [Hash]
      def to_h
        {
          header: @header,
          nmi: @nmi.nmi,
          nmi_configuration: @nmi_configuration,
          next_scheduled_read_date: @next_scheduled_read_date,
          # @todo Move this to AEMO::NMI::Meter
          meter_serial_number: @meter_serial_number,
          # @todo AEMO::NMI::Register - interval data and events to be children of the register of the meter?.
          register_id: @register_id,
          nmi_suffix: @nmi_suffix,
          mdm_data_streaming_identifier: @mdm_data_streaming_identifier,
          unit_of_measurement: @unit_of_measurement,
          interval_length: @interval_length
        }
      end

      # Return in Hash format
      #
      # @return [String]
      def to_json
        to_h.to_json
      end

      #
      def validate_string_pattern(key, string, pattern)
        AEMO.validate_string_pattern(key, string, pattern)
      end
    end
  end
end
