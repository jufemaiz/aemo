module AEMO
  class NMI
    class Register

      DATA_STREAM_SUFFIX = {
        # Averaged Data Streams
        'A' => { :stream => 'Average', :description => 'Import', :units => 'kWh' },
        'D' => { :stream => 'Average', :description => 'Export', :units => 'kWh' },
        'J' => { :stream => 'Average', :description => 'Import', :units => 'kVArh' },
        'P' => { :stream => 'Average', :description => 'Export', :units => 'kVArh' },
        'S' => { :stream => 'Average', :description => '',       :units => 'kVAh' },
        # Master Data Streams
        'B' => { :stream => 'Master',  :description => 'Import', :units => 'kWh' },
        'E' => { :stream => 'Master',  :description => 'Export', :units => 'kWh' },
        'K' => { :stream => 'Master',  :description => 'Import', :units => 'kVArh' },
        'Q' => { :stream => 'Master',  :description => 'Export', :units => 'kVArh' },
        'T' => { :stream => 'Master',  :description => '',       :units => 'kVAh' },
        'G' => { :stream => 'Master',  :description => 'Power Factor',       :units => 'PF' },
        'H' => { :stream => 'Master',  :description => 'Q Metering',         :units => 'Qh' },
        'M' => { :stream => 'Master',  :description => 'Par Metering',  :units => 'parh' },
        'V' => { :stream => 'Master',  :description => 'Volts or V2h or Amps or A2h',  :units => '' },
        # Check Meter Streams
        'C' => { :stream => 'Check',  :description => 'Import', :units => 'kWh' },
        'F' => { :stream => 'Check',  :description => 'Export', :units => 'kWh' },
        'L' => { :stream => 'Check',  :description => 'Import', :units => 'kVArh' },
        'R' => { :stream => 'Check',  :description => 'Export', :units => 'kVArh' },
        'U' => { :stream => 'Check',  :description => '',       :units => 'kVAh' },
        'Y' => { :stream => 'Check',  :description => 'Q Metering',         :units => 'Qh' },
        'W' => { :stream => 'Check',  :description => 'Par Metering Path',  :units => '' },
        'Z' => { :stream => 'Check',  :description => 'Volts or V2h or Amps or A2h',  :units => '' },
        # Net Meter Streams
        # AEMO: NOTE THAT D AND J ARE PREVIOUSLY DEFINED
        # 'D' => { :stream => 'Net',    :description => 'Net', :units => 'kWh' },
        # 'J' => { :stream => 'Net',    :description => 'Net', :units => 'kVArh' }
      }

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

      def initilize(suffix, register_id, unit_of_measure, options={})
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
      end
    end
  end
end
