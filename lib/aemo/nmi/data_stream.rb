# encoding: UTF-8
require 'active_support/all'

module AEMO
  class NMI
    # [AEMO::NMI::DataStream]
    #
    # @author Joel Courtney
    # @abstract
    # @since 0.2.0
    # @attr [String] suffix
    # @attr [String] profile_name
    # @attr [Integer] average_daily_load
    # @attr [String] data_stream_type
    # @attr [String] status
    class DataStream
      SUFFIXES = {
        # Averaged Data Streams
        'A' => { stream: 'Average', description: 'Import', units: 'kWh' },
        'D' => { stream: 'Average', description: 'Export', units: 'kWh' },
        'J' => { stream: 'Average', description: 'Import', units: 'kVArh' },
        'P' => { stream: 'Average', description: 'Export', units: 'kVArh' },
        'S' => { stream: 'Average', description: '',       units: 'kVAh' },
        # Master Data Streams
        'B' => { stream: 'Master',  description: 'Import', units: 'kWh' },
        'E' => { stream: 'Master',  description: 'Export', units: 'kWh' },
        'K' => { stream: 'Master',  description: 'Import', units: 'kVArh' },
        'Q' => { stream: 'Master',  description: 'Export', units: 'kVArh' },
        'T' => { stream: 'Master',  description: '',       units: 'kVAh' },
        'G' => { stream: 'Master',  description: 'Power Factor',       units: 'PF' },
        'H' => { stream: 'Master',  description: 'Q Metering',         units: 'Qh' },
        'M' => { stream: 'Master',  description: 'Par Metering',  units: 'parh' },
        'V' => { stream: 'Master',  description: 'Volts or V2h or Amps or A2h', units: '' },
        # Check Meter Streams
        'C' => { stream: 'Check',  description: 'Import', units: 'kWh' },
        'F' => { stream: 'Check',  description: 'Export', units: 'kWh' },
        'L' => { stream: 'Check',  description: 'Import', units: 'kVArh' },
        'R' => { stream: 'Check',  description: 'Export', units: 'kVArh' },
        'U' => { stream: 'Check',  description: '',       units: 'kVAh' },
        'Y' => { stream: 'Check',  description: 'Q Metering',         units: 'Qh' },
        'W' => { stream: 'Check',  description: 'Par Metering Path',  units: '' },
        'Z' => { stream: 'Check',  description: 'Volts or V2h or Amps or A2h',  units: '' },
        # Net Meter Streams
        # AEMO: NOTE THAT D AND J ARE PREVIOUSLY DEFINED
        # 'D' => { :stream => 'Net',    :description => 'Net', :units => 'kWh' },
        # 'J' => { :stream => 'Net',    :description => 'Net', :units => 'kVArh' }
      }.freeze

      @suffix = nil
      @profile_name = nil
      @average_daily_load = 0
      @data_stream_type = nil
      @status = nil

      attr_accessor :suffix, :profile_name, :average_daily_load, :data_stream_type, :status
      class << self
        # Returns an array of DataStreams
        #
        # @param [Array<Hash>, Hash] data either a single data stream or array of data streams in MSATS format
        # @return [Array<AEMO::NMI::DataStream>]
        def parse_msats_hash(data)
          data_streams = []
          data = [data] if data.is_a?(Hash)
          data.each do |datum|
            data_streams << AEMO::NMI::DataStream.new(
              suffix: datum['Suffix'],
              profile_name: datum['ProfileName'],
              averaged_daily_load: datum['AveragedDailyLoad'].to_i,
              data_stream_type: datum['DataStreamType'],
              status: datum['Status']
            )
          end
          data_streams
        end
      end

      # Creates a new AEMO::NMI::DataStream
      #
      # @param [Hash] options
      # @option options [String] :suffix
      # @option options [String] :profile_name
      # @option options [Numeric] :averaged_daily_load
      # @option options [String] :data_stream_type
      # @option options [String] :status
      # @return [AEMO::NMI::DataStream]
      def initialize(options = {})
        @suffix = options[:suffix]
        @profile_name = options[:profile_name]
        unless options[:averaged_daily_load].nil?
          raise ArgumentError, 'averaged_daily_load is not a number' unless options[:averaged_daily_load].is_a?(Numeric)
          @averaged_daily_load = options[:averaged_daily_load]
        end
        @data_stream_type = options[:data_stream_type]
        @status = options[:status]
      end

      # Is the DataStream active?
      #
      # @return [Boolean]
      def active?
        @status == 'A'
      end

      # Is the DataStream inactive?
      #
      # @return [Boolean]
      def inactive?
        !active?
      end

      # The current annual load in kWh
      #
      # @return [Numeric] the current annual load for the meter
      def current_annual_load
        (@averaged_daily_load * 365.2425)
      end
    end
  end
end
