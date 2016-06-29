# encoding: UTF-8

require 'csv'
require 'json'
require 'time'
require 'ostruct'
require 'active_support'

require_relative 'nmi/unit_of_measurement'
require_relative 'nmi/allocations'
require_relative 'nmi/loss_factors'
require_relative 'nmi/address'
require_relative 'nmi/meter'
require_relative 'nmi/register'

module AEMO
  # [AEMO::NMI]
  # AEMO::NMI acts as an object to simplify access to data and information about a NMI and provide verification of the NMI value
  #
  # @author Joel Courtney
  # @abstract
  # @since 0.1.0, overhauled 0.2.0
  # @attr [String] nmi
  # @attr [Hash] msats_detail
  # @attr [String] tni
  # @attr [String] dlf
  # @attr [String] customer_classification_code
  # @attr [String] customer_threshold_code
  # @attr [String] jurisdiction_code
  # @attr [String] classification_code
  # @attr [String] status
  # @attr [Hash] address
  # @attr [Array] meters
  # @attr [Hash] roles
  # @attr [Array] data_streams
  class NMI
    # [String] National Meter Identifier
    @nmi                          = nil
    @msats_detail                 = {}
    @tni                          = nil
    @dlf                          = nil
    @customer_classification_code = nil
    @customer_threshold_code      = nil
    @jurisdiction_code            = nil
    @classification_code          = nil
    @status                       = nil
    @address                      = {}
    @meters                       = []
    @roles                        = {}
    @data_streams                 = []

    attr_accessor :nmi, :tni, :dlf, :customer_classification_code, :customer_threshold_code, :jurisdiction_code, :classification_code, :status, :address, :meters, :roles, :data_streams
    attr_reader   :msats_detail

    class << self
      # A function to validate the NMI provided
      #
      # @param [String] nmi the nmi to be checked
      # @return [Boolean] whether or not the nmi is valid
      def valid_nmi?(nmi)
        ((nmi.length == 10) && !nmi.match(/^([A-HJ-NP-Z\d]{10})/).nil?)
      end

      # A function to calculate the checksum value for a given National Meter Identifier
      #
      # @param [String] nmi the NMI to check the checksum against
      # @param [Integer] checksum_value the checksum value to check against the current National Meter Identifier's checksum value
      # @return [Boolean] whether or not the checksum is valid
      def valid_checksum?(nmi, checksum_value)
        nmi = AEMO::NMI.new(nmi)
        nmi.valid_checksum?(checksum_value)
      end

      # Find the Network for a given NMI
      #
      # @param [String] nmi NMI
      # @returns [Hash] The Network information
      def network(nmi)
        network = nil
        AEMO::NMI::NMI_ALLOCATIONS.each_pair do |identifier, details|
          details[:includes].each do |pattern|
            if nmi.match(pattern)
              network = { identifier => details }
              break
            end
          end
        end
        network
      end
    end

    # Initialize a NMI file
    #
    # @param [String] nmi the National Meter Identifier (NMI)
    # @param [Hash] options a hash of options
    # @option options [String] :nmi_configuration
    # @option options [Date] :next_scheduled_read_date
    # @option options [String] :meter_serial_number
    # @option options [String] :register_id
    # @option options [String] :nmi_suffix
    # @option options [String] :mdm_data_streaming_identifier
    # @option options [Integer] :interval_length
    # @option options [String, AEMO::NMI::UnitOfMeasurement] :unit_of_measurement
    # @option options [String] :tni
    # @option options [String] :dlf
    # @option options [String] :customer_classification_code
    # @option options [String] :customer_threshold_code
    # @option options [String] :jurisdiction_code
    # @option options [String] :classification_code
    # @option options [String] :status
    # @option options [String] :address
    # @option options [Array<AEMO::NMI::Meter>] :meters
    # @option options [String] :roles
    # @option options [Array<AEMO::NMI::DataStream>] :data_streams
    # @return [AEMO::NMI] an instance of AEMO::NMI is returned
    def initialize(nmi, options={})
      # Validations
      raise ArgumentError, 'NMI is not a string'                          unless nmi.is_a?(String)
      raise ArgumentError, 'NMI is not 10 characters'                     unless nmi.length == 10
      raise ArgumentError, 'NMI is not constructed with valid characters' unless AEMO::NMI.valid_nmi?(nmi)

      # National Meter Identifier
      @nmi = nmi

      # Roles
      unless options[:roles].nil?
        raise ArgumentError, 'Role is not valid' unless options[:roles].is_a?(String)
        @roles  = options[:roles]
      end

      # Meters are based upon
      unless options[:nmi_configuration].nil?
        raise 'NMI Configuration is not a string' unless options[:nmi_configuration].is_a?(String)
        raise "NMI Configuration #{options[:nmi_configuration]} is invalid" unless options[:nmi_configuration].match(/^([A-Z]\d+)+$/)
        options[:nmi_configuration].scan(/([A-Z]\d+)/).flatten.group_by { |x| x.match(/[A-Z](\d+)/)[1].to_i }.each do |meter, registers|
          @meters ||= []
          @meters << AEMO::NMI::Meter.new({ nem12_meter: meter, registers: registers.join() })
        end
      end

      unless options[:next_scheduled_read_date].nil?
        raise ArgumentError, 'Next Scheduled Read Date is invalid' unless options[:next_scheduled_read_date].is_a?(Date)
        @next_scheduled_read_date = options[:next_scheduled_read_date]
      end

      unless options[:meter_serial_number].nil?
        raise ArgumentError, 'Meter Serial Number is invalid' unless options[:meter_serial_number].is_a?(String)
        @meter_serial_number = options[:meter_serial_number]
      end

      unless options[:register_id].nil?
        raise ArgumentError, 'Register ID is invalid' unless options[:register_id].is_a?(String)
        @register_id = options[:register_id]
      end

      unless options[:nmi_suffix].nil?
        raise ArgumentError, 'NMI Suffix is invalid' unless options[:nmi_suffix].is_a?(String)
        @nmi_suffix = options[:nmi_suffix]
      end

      unless options[:mdm_data_streaming_identifier].nil?
        raise ArgumentError, 'MDM Data Streaming Identifier is invalid' unless options[:mdm_data_streaming_identifier].is_a?(String)
        raise ArgumentError, 'MDM Data Streaming Identifier is invalid' unless options[:mdm_data_streaming_identifier].match(/^[A-Z0-9]+$/)
        @mdm_data_streaming_identifier = options[:mdm_data_streaming_identifier]
      end

      unless options[:unit_of_measurement].nil?
        raise ArgumentError, 'Unit of Measurement is invalid' unless options[:unit_of_measurement].is_a?(String)
        @unit_of_measurement = AEMO::NMI::UnitOfMeasurement.new(options[:unit_of_measurement])
      end

      unless options[:interval_length].nil?
        raise ArgumentError, '' unless options[:interval_length].is_a?(Numeric)
        @interval_length = options[:interval_length]
      end
    end

    # A function to validate the instance's nmi value
    #
    # @return [Boolean] whether or not the nmi is valid
    def valid_nmi?
      AEMO::NMI.valid_nmi?(@nmi)
    end

    # Find the Network of NMI
    #
    # @return [Hash] The Network information
    def network
      AEMO::NMI.network(@nmi)
    end

    # Updates Register information
    #
    # @param [String] register_id
    # @param [Hash] options
    # @return [self]
    def update_register_details(register_id, options = {})
      register = @meters.map { |meter| meter.registers }.select { |register| register.register_id == register_id }
      return self if register.nil?
    end

    # A function to calculate the checksum value for a given National Meter Identifier
    #
    # @param [Integer] checksum_value the checksum value to check against the current National Meter Identifier's checksum value
    # @return [Boolean] whether or not the checksum is valid
    def valid_checksum?(checksum_value)
      checksum_value == checksum
    end

    # Checksum is a function to calculate the checksum value for a given National Meter Identifier
    #
    # @return [Integer] the checksum value for the current National Meter Identifier
    def checksum
      summation = 0
      @nmi.reverse.split(//).each_index do |i|
        value = nmi[nmi.length - i - 1].ord
        value *= 2 if i.even?
        value = value.to_s.split(//).map(&:to_i).reduce(:+)
        summation += value
      end
      checksum = (10 - (summation % 10)) % 10
      checksum
    end

    # Provided MSATS is configured, gets the MSATS data for the NMI
    #
    # @return [Hash] MSATS NMI Detail data
    def raw_msats_nmi_detail(options = {})
      raise ArgumentError,
            'MSATS has no authentication credentials' unless AEMO::MSATS.can_authenticate?

      AEMO::MSATS.nmi_detail(@nmi, options)
    end

    # Provided MSATS is configured, uses the raw MSATS data to augment NMI information
    #
    # @return [self] returns self
    def update_from_msats!(options = {})
      # Update local cache
      @msats_detail = raw_msats_nmi_detail(options)
      parse_msats_detail
      self
    end

    # Turns raw MSATS junk into useful things
    #
    # @return [self] returns self
    def parse_msats_detail
      # Set the details if there are any
      unless @msats_detail['MasterData'].nil?
        @tni                          = @msats_detail['MasterData']['TransmissionNodeIdentifier']
        @dlf                          = @msats_detail['MasterData']['DistributionLossFactorCode']
        @customer_classification_code = @msats_detail['MasterData']['CustomerClassificationCode']
        @customer_threshold_code      = @msats_detail['MasterData']['CustomerThresholdCode']
        @jurisdiction_code            = @msats_detail['MasterData']['JurisdictionCode']
        @classification_code          = @msats_detail['MasterData']['NMIClassificationCode']
        @status                       = @msats_detail['MasterData']['Status']
        @address                      = AEMO::NMI::Address.parse_msats_hash(@msats_detail['MasterData']['Address'])
      end
      @meters                       ||= []
      @roles                        ||= {}
      @data_streams                 ||= []
      # Meters
      unless @msats_detail['MeterRegister'].nil?
        meters = @msats_detail['MeterRegister']['Meter']
        meters = [meters] if meters.is_a?(Hash)
        meters.select { |x| !x['Status'].nil? }.each do |meter|
          @meters << OpenStruct.new(
            status: meter['Status'],
            installation_type_code: meter['InstallationTypeCode'],
            next_scheduled_read_date: meter['NextScheduledReadDate'],
            read_type_code: meter['ReadTypeCode'],
            registers: [],
            serial_number: meter['SerialNumber']
          )
        end
        meters.select { |x| x['Status'].nil? }.each do |registers|
          m = @meters.find { |x| x.serial_number == registers['SerialNumber'] }
          m.registers << OpenStruct.new(
            controlled_load: (registers['RegisterConfiguration']['Register']['ControlledLoad'] == 'Y'),
            dial_format: registers['RegisterConfiguration']['Register']['DialFormat'],
            multiplier: registers['RegisterConfiguration']['Register']['Multiplier'],
            network_tariff_code: registers['RegisterConfiguration']['Register']['NetworkTariffCode'],
            register_id: registers['RegisterConfiguration']['Register']['RegisterID'],
            status: registers['RegisterConfiguration']['Register']['Status'],
            time_of_day: registers['RegisterConfiguration']['Register']['TimeOfDay'],
            unit_of_measure: registers['RegisterConfiguration']['Register']['UnitOfMeasure']
          )
        end
      end
      # Roles
      unless @msats_detail['RoleAssignments'].nil?
        role_assignments = @msats_detail['RoleAssignments']['RoleAssignment']
        role_assignments = [role_assignments] if role_assignments.is_a?(Hash)
        role_assignments.each do |role|
          @roles[role['Role']] = role['Party']
        end
      end
      # DataStreams
      unless @msats_detail['DataStreams'].nil?
        data_streams = @msats_detail['DataStreams']['DataStream']
        data_streams = [data_streams] if data_streams.is_a?(Hash) # Deal with issue of only one existing
        data_streams.each do |stream|
          @data_streams << OpenStruct.new(
            suffix: stream['Suffix'],
            profile_name: stream['ProfileName'],
            averaged_daily_load: stream['AveragedDailyLoad'],
            data_stream_type: stream['DataStreamType'],
            status: stream['Status']
          )
        end
      end
      self
    end

    # Returns a nice address from the structured one AEMO sends us
    #
    # @return [String]
    def friendly_address
      if @address.is_a?(Hash)
        friendly_address = @address.values.map do |x|
          if x.is_a?(Hash)
            x = x.values.map { |y| y.is_a?(Hash) ? y.values.join(' ') : y }.join(' ')
          end
          x
        end.join(', ')
      else
        ''
      end
    end

    # Returns the meter OpenStructs for the requested status (C/R)
    #
    # @param [String] status the stateus [C|R]
    # @return [Array<OpenStruct>] Returns an array of OpenStructs for Meters with the status provided
    def meters_by_status(status = 'C')
      @meters.select { |x| x.status == status.to_s }
    end

    # Returns the data_stream OpenStructs for the requested status (A/I)
    #
    # @param [String] status the stateus [A|I]
    # @return [Array<OpenStruct>] Returns an array of OpenStructs for the current Meters
    def data_streams_by_status(status = 'A')
      if @data_streams.nil?
        []
      else
        @data_streams.select { |x| x.status == status.to_s }
      end
    end

    # The current daily load in kWh
    #
    # @return [Integer] the current daily load for the meter in kWh
    def current_daily_load
      data_streams_by_status.map { |x| x.averaged_daily_load.to_i }.inject(0, :+)
    end

    # The current annual load in MWh
    #
    # @return [Integer] the current annual load for the meter in MWh
    def current_annual_load
      (current_daily_load * 365.2425 / 1000).to_i
    end

    # A function to return the distribution loss factor value for a given date
    #
    # @param [DateTime, Time] datetime the date for the distribution loss factor value
    # @return [nil, float] the distribution loss factor value
    def dlfc_value(datetime = DateTime.now)
      raise 'No DLF set, ensure that you have set the value either via the update_from_msats! function or manually' if @dlf.nil?
      raise 'DLF is invalid' unless DLF_CODES.keys.include?(@dlf)
      raise 'Invalid date' unless [DateTime, Time].include?(datetime.class)
      possible_values = DLF_CODES[@dlf].select { |x| DateTime.parse(x['FromDate']) <= datetime && datetime <= DateTime.parse(x['ToDate']) }
      if possible_values.empty?
        nil
      else
        possible_values.first['Value'].to_f
      end
    end

    # A function to return the distribution loss factor value for a given date
    #
    # @param [DateTime, Time] start the date for the distribution loss factor value
    # @param [DateTime, Time] finish the date for the distribution loss factor value
    # @return [Array(Hash)] array of hashes of start, finish and value
    def dlfc_values(start = DateTime.now, finish = DateTime.now)
      raise 'No DLF set, ensure that you have set the value either via the update_from_msats! function or manually' if @dlf.nil?
      raise 'DLF is invalid' unless DLF_CODES.keys.include?(@dlf)
      raise 'Invalid start' unless [DateTime, Time].include?(start.class)
      raise 'Invalid finish' unless [DateTime, Time].include?(finish.class)
      raise 'start cannot be after finish' if start > finish
      DLF_CODES[@dlf].reject { |x| start > DateTime.parse(x['ToDate']) || finish < DateTime.parse(x['FromDate']) }
                     .map { |x| { 'start' => x['FromDate'], 'finish' => x['ToDate'], 'value' => x['Value'].to_f } }
    end

    # A function to return the transmission node identifier loss factor value for a given date
    #
    # @param [DateTime, Time] datetime the date for the distribution loss factor value
    # @return [nil, float] the transmission node identifier loss factor value
    def tni_value(datetime = DateTime.now)
      raise 'No TNI set, ensure that you have set the value either via the update_from_msats! function or manually' if @tni.nil?
      raise 'TNI is invalid' unless TNI_CODES.keys.include?(@tni)
      raise 'Invalid date' unless [DateTime, Time].include?(datetime.class)
      possible_values = TNI_CODES[@tni].select { |x| DateTime.parse(x['FromDate']) <= datetime && datetime <= DateTime.parse(x['ToDate']) }
      return nil if possible_values.empty?
      possible_values = possible_values.first['mlf_data']['loss_factors'].select { |x| DateTime.parse(x['start']) <= datetime && datetime <= DateTime.parse(x['finish']) }
      return nil if possible_values.empty?
      possible_values.first['value'].to_f
    end

    # A function to return the transmission node identifier loss factor value for a given date
    #
    # @param [DateTime, Time] start the date for the distribution loss factor value
    # @param [DateTime, Time] finish the date for the distribution loss factor value
    # @return [Array(Hash)] array of hashes of start, finish and value
    def tni_values(start = DateTime.now, finish = DateTime.now)
      raise 'No TNI set, ensure that you have set the value either via the update_from_msats! function or manually' if @tni.nil?
      raise 'TNI is invalid' unless TNI_CODES.keys.include?(@tni)
      raise 'Invalid start' unless [DateTime, Time].include?(start.class)
      raise 'Invalid finish' unless [DateTime, Time].include?(finish.class)
      raise 'start cannot be after finish' if start > finish
      possible_values = TNI_CODES[@tni]
                        .reject { |x| start > DateTime.parse(x['ToDate']) || finish < DateTime.parse(x['FromDate']) }
                        # .map { |x| { 'start' => x['FromDate'], 'finish' => x['ToDate'], 'value' => x['Value'].to_f } }
      return [] if possible_values.empty?
      possible_values.map { |x| x['mlf_data']['loss_factors'] }
        .flatten
        .reject{ |x| start > DateTime.parse(x['finish']) || finish < DateTime.parse(x['start']) }
    end
  end
end
