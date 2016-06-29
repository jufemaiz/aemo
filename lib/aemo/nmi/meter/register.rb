# encoding: UTF-8

module AEMO
  class NMI
    class Meter
      # [AEMO::NMI::Meter::Register]
      #
      # @author Joel Courtney
      # @abstract
      # @since 0.2.0
      # @attr [DateTime] file_created_at DateTime that the file was created at
      # @attr [String] from_participant The originator of the NEM12 file
      # @attr [String] to_participant The recipient of the NEM12 file
      class Register
        # NMI Lookup + NEM12 File
        @suffix                         = nil
        @register_id                    = nil
        @unit_of_measure                = nil

        # Details from NMI Lookup
        @network_tariff_code            = nil
        @time_of_day                    = nil
        @multiplier                     = nil
        @dial_format                    = nil
        @controlled_load                = nil
        @status                         = nil

        # Additional Data from NEM12 File
        @mdm_data_streaming_identifier  = nil
        @interval_length                = nil

        attr_accessor :suffix, :register_id, :unit_of_measure, :network_tariff_code, :time_of_day, :multiplier, :dial_format, :controlled_load, :status, :mdm_data_streaming_identifier, :interval_length

        def initialize(suffix, register_id, unit_of_measure, options = {})
          @suffix           = suffix
          @register_id      = register_id
          @unit_of_measure  = unit_of_measure

          # Options
          @network_tariff_code = options[:network_tariff_code]
          @time_of_day = options[:time_of_day]
          @multiplier = options[:multiplier]
          @dial_format = options[:dial_format]
          @controlled_load = options[:controlled_load]
          @status = options[:status]
          @mdm_data_streaming_identifier = options[:mdm_data_streaming_identifier]
          @interval_length = options[:interval_length]

          self
        end
      end
    end
  end
end
