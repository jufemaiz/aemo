# frozen_string_literal: true

require 'csv'
require 'json'
require 'time'
require 'ostruct'

require 'aemo/nmi/allocation'

module AEMO
  # [AEMO::NMI]
  #
  # AEMO::NMI acts as an object to simplify access to data and information
  #   about a NMI and provide verification of the NMI value
  #
  # @author Joel Courtney
  # @abstract Model for a National Metering Identifier.
  # @since 2014-12-05
  class NMI
    # Operational Regions for the NMI
    REGIONS = {
      'ACT' => 'Australian Capital Territory',
      'NSW' => 'New South Wales',
      'QLD' => 'Queensland',
      'SA' => 'South Australia',
      'TAS' => 'Tasmania',
      'VIC' => 'Victoria',
      'WA' => 'Western Australia',
      'NT' => 'Northern Territory'
    }.freeze

    # Transmission Node Identifier Codes are loaded from a json file
    #  Obtained from http://www.nemweb.com.au/
    #
    #  See /lib/data for further data manipulation required
    TNI_CODES = JSON.parse(
      File.read(
        File.join(File.dirname(__FILE__), '..', 'data', 'aemo-tni.json')
      )
    ).freeze

    # Distribution Loss Factor Codes are loaded from a json file
    #  Obtained from MSATS, matching to DNSP from file
    # https://www.aemo.com.au/-/media/Files/Electricity/NEM/
    #   Security_and_Reliability/Loss_Factors_and_Regional_Boundaries/
    #   2016/DLF_V3_2016_2017.pdf
    #
    #  Last accessed 2017-08-01
    #  See /lib/data for further data manipulation required
    DLF_CODES = JSON.parse(
      File.read(
        File.join(File.dirname(__FILE__), '..', 'data', 'aemo-dlf.json')
      )
    ).freeze

    # [String] National Meter Identifier
    @nmi                          = nil
    @msats_detail                 = nil
    @tni                          = nil
    @dlf                          = nil
    @customer_classification_code = nil
    @customer_threshold_code      = nil
    @jurisdiction_code            = nil
    @classification_code          = nil
    @status                       = nil
    @address                      = nil
    @meters                       = nil
    @roles                        = nil
    @data_streams                 = nil

    attr_accessor :nmi, :msats_detail, :tni, :dlf,
                  :customer_classification_code, :customer_threshold_code,
                  :jurisdiction_code, :classification_code, :status, :address,
                  :meters, :roles, :data_streams

    class << self
      # A function to validate the NMI provided
      #
      # @param [String] nmi the nmi to be checked
      # @return [Boolean] whether or not the nmi is valid
      def valid_nmi?(nmi)
        (nmi.length == 10) && !nmi.match(/^([A-HJ-NP-Z\d]{10})/).nil?
      end

      # A function to calculate the checksum value for a given National Meter
      # Identifier
      #
      # @param [String] nmi the NMI to check the checksum against
      # @param [Integer] checksum_value the checksum value to check against the
      #   current National Meter Identifier's checksum value
      # @return [Boolean] whether or not the checksum is valid
      def valid_checksum?(nmi, checksum_value)
        nmi = AEMO::NMI.new(nmi)
        nmi.valid_checksum?(checksum_value)
      end

      # Find the Network for a given NMI
      #
      # @param [String] nmi NMI
      # @returns [AEMO::NMI::Allocation] The Network information
      def network(nmi)
        AEMO::NMI::Allocation.find_by_nmi(nmi)
      end

      alias allocation network
    end

    # Initialize a NMI file
    #
    # @param [String] nmi the National Meter Identifier (NMI)
    # @param [Hash] options a hash of options
    # @option options [Hash] :msats_detail MSATS details as per
    #   #parse_msats_detail requirements
    # @return [AEMO::NMI] an instance of AEMO::NMI is returned
    def initialize(nmi, options = {})
      raise ArgumentError, 'NMI is not a string' unless nmi.is_a?(String)
      raise ArgumentError, 'NMI is not 10 characters' unless nmi.length == 10
      raise ArgumentError, 'NMI is not constructed with valid characters' unless AEMO::NMI.valid_nmi?(nmi)

      @nmi          = nmi
      @meters       = []
      @roles        = {}
      @data_streams = []
      @msats_detail = options[:msats_detail]

      parse_msats_detail unless @msats_detail.nil?
    end

    # A function to validate the instance's nmi value
    #
    # @return [Boolean] whether or not the nmi is valid
    def valid_nmi?
      AEMO::NMI.valid_nmi?(@nmi)
    end

    # Find the Network of NMI
    #
    # @returns [Hash] The Network information
    def network
      AEMO::NMI.network(@nmi)
    end

    alias allocation network

    # A function to calculate the checksum value for a given
    # National Meter Identifier
    #
    # @param [Integer] checksum_value the checksum value to check against the
    #   current National Meter Identifier's checksum value
    # @return [Boolean] whether or not the checksum is valid
    def valid_checksum?(checksum_value)
      checksum_value == checksum
    end

    # Checksum is a function to calculate the checksum value for a given
    # National Meter Identifier
    #
    # @return [Integer] the checksum value for the current National Meter
    #   Identifier
    def checksum
      summation = 0
      @nmi.reverse.chars.each_index do |i|
        value = nmi[nmi.length - i - 1].ord
        value *= 2 if i.even?
        value = value.to_s.chars.map(&:to_i).reduce(:+)
        summation += value
      end
      (10 - (summation % 10)) % 10
    end

    # Provided MSATS is configured, gets the MSATS data for the NMI
    #
    # @return [Hash] MSATS NMI Detail data
    def raw_msats_nmi_detail(options = {})
      raise ArgumentError, 'MSATS has no authentication credentials' unless AEMO::MSATS.can_authenticate?

      AEMO::MSATS.nmi_detail(@nmi, options)
    end

    # Provided MSATS is configured, uses the raw MSATS data to augment NMI
    # information
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
        @address                      = @msats_detail['MasterData']['Address']
      end
      @meters                       ||= []
      @roles                        ||= {}
      @data_streams                 ||= []
      # Meters
      unless @msats_detail['MeterRegister'].nil?
        meters = @msats_detail['MeterRegister']['Meter']
        meters = [meters] if meters.is_a?(Hash)
        meters.reject { |x| x['Status'].nil? }.each do |meter|
          @meters << AEMO::Meter.from_hash(meter)
        end
        meters.select { |x| x['Status'].nil? }.each do |registers|
          m = @meters.find { |x| x.serial_number == registers['SerialNumber'] }
          m.registers << AEMO::Register.from_hash(
            registers['RegisterConfiguration']['Register']
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
          @data_streams << Struct::DataStream.new(
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
      friendly_address = ''
      if @address.is_a?(Hash)
        friendly_address = @address.values.map do |x|
          if x.is_a?(Hash)
            x = x.values.map { |y| y.is_a?(Hash) ? y.values.join(' ') : y }.join(' ')
          end
          x
        end.join(', ')
      end
      friendly_address
    end

    # Returns the meters for the requested status (C/R)
    #
    # @param [String] status the stateus [C|R]
    # @return [Array<AEMO::Meter>] Returns an array of AEMO::Meters with the
    #   status provided
    def meters_by_status(status = 'C')
      @meters.select { |x| x.status == status.to_s }
    end

    # Returns the data_stream Structs for the requested status (A/I)
    #
    # @param [String] status the stateus [A|I]
    # @return [Array<Struct>] Returns an array of Structs for the
    #   current Meters
    def data_streams_by_status(status = 'A')
      @data_streams.select { |x| x.status == status.to_s }
    end

    # The current daily load in kWh
    #
    # @return [Integer] the current daily load for the meter in kWh
    def current_daily_load
      data_streams_by_status.map { |x| x.averaged_daily_load.to_i }
                            .inject(0, :+)
    end

    # The current annual load in MWh
    #
    # @todo Use TimeDifference for more accurate annualised load
    # @return [Integer] the current annual load for the meter in MWh
    def current_annual_load
      (current_daily_load * 365.2425 / 1000).to_i
    end

    # A function to return the distribution loss factor value for a given date
    #
    # @param [DateTime, Time] datetime the date for the distribution loss factor
    #   value
    # @return [nil, float] the distribution loss factor value
    def dlfc_value(datetime = Time.now)
      if @dlf.nil?
        raise 'No DLF set, ensure that you have set the value either via the' \
              'update_from_msats! function or manually'
      end
      raise 'DLF is invalid' unless DLF_CODES.keys.include?(@dlf)
      raise 'Invalid date' unless [DateTime, Time].include?(datetime.class)

      possible_values = DLF_CODES[@dlf].select do |x|
        Time.parse(x['FromDate']) <= datetime &&
          Time.parse(x['ToDate']) >= datetime
      end
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
    def dlfc_values(start = Time.now, finish = Time.now)
      if @dlf.nil?
        raise 'No DLF set, ensure that you have set the value either via the ' \
              'update_from_msats! function or manually'
      end
      raise 'DLF is invalid' unless DLF_CODES.keys.include?(@dlf)
      raise 'Invalid start' unless [DateTime, Time].include?(start.class)
      raise 'Invalid finish' unless [DateTime, Time].include?(finish.class)
      raise 'start cannot be after finish' if start > finish

      DLF_CODES[@dlf].reject { |x| start > Time.parse(x['ToDate']) || finish < Time.parse(x['FromDate']) }
                     .map { |x| { 'start' => x['FromDate'], 'finish' => x['ToDate'], 'value' => x['Value'].to_f } }
    end

    # A function to return the transmission node identifier loss factor value for a given date
    #
    # @param [DateTime, Time] datetime the date for the distribution loss factor value
    # @return [nil, float] the transmission node identifier loss factor value
    def tni_value(datetime = Time.now)
      if @tni.nil?
        raise 'No TNI set, ensure that you have set the value either via the ' \
              'update_from_msats! function or manually'
      end
      raise 'TNI is invalid' unless TNI_CODES.keys.include?(@tni)
      raise 'Invalid date' unless [DateTime, Time].include?(datetime.class)

      possible_values = TNI_CODES[@tni].select do |x|
        Time.parse(x['FromDate']) <= datetime && datetime <= Time.parse(x['ToDate'])
      end
      return nil if possible_values.empty?

      possible_values = possible_values.first['mlf_data']['loss_factors'].select do |x|
        Time.parse(x['start']) <= datetime && datetime <= Time.parse(x['finish'])
      end
      return nil if possible_values.empty?

      possible_values.first['value'].to_f
    end

    # A function to return the transmission node identifier loss factor value for a given date
    #
    # @param [DateTime, Time] start the date for the distribution loss factor value
    # @param [DateTime, Time] finish the date for the distribution loss factor value
    # @return [Array(Hash)] array of hashes of start, finish and value
    def tni_values(start = Time.now, finish = Time.now)
      if @tni.nil?
        raise 'No TNI set, ensure that you have set the value either via the ' \
              'update_from_msats! function or manually'
      end
      raise 'TNI is invalid' unless TNI_CODES.keys.include?(@tni)
      raise 'Invalid start' unless [DateTime, Time].include?(start.class)
      raise 'Invalid finish' unless [DateTime, Time].include?(finish.class)
      raise 'start cannot be after finish' if start > finish

      possible_values = TNI_CODES[@tni].reject do |tni_code|
        start > Time.parse(tni_code['ToDate']) ||
          finish < Time.parse(tni_code['FromDate'])
      end

      return nil if possible_values.empty?

      possible_values.map { |x| x['mlf_data']['loss_factors'] }
    end
  end
end
