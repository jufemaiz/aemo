require 'csv'
require 'json'
require 'time'
require 'ostruct'
module AEMO
  # AEMO::NMI acts as an object to simplify access to data and information about a NMI and provide verification of the NMI value
  class NMI
    # Operational Regions for the NMI
    REGIONS = {
      'ACT' => 'Australian Capital Territory',
      'NSW' => 'New South Wales',
      'QLD' => 'Queensland',
      'SA'  => 'South Australia',
      'TAS' => 'Tasmania',
      'VIC' => 'Victoria',
      'WA'  => 'Western Australia',
      'NT'  => 'Northern Territory'
    }.freeze

    # NMI_ALLOCATIONS as per AEMO Documentation at http://aemo.com.au/Electricity/Policies-and-Procedures/Retail-and-Metering/~/media/Files/Other/Retail% 20and% 20Metering/NMI_Allocation_List_v7_June_2012.ashx
    #   Last accessed 2016-05-15
    NMI_ALLOCATIONS = {
      'ACTEWP' => {
        title: 'Actew Distribution Ltd and Jemena Networks (ACT) Pty Ltd',
        friendly_title: 'ACTEWAgl',
        state: 'ACT',
        type: 'electricity',
        includes: [
          /^(NGGG[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(7001\d{6})$/
        ],
        excludes: [
        ]
      },
      'CNRGYP' => {
        title: 'Essential Energy',
        friendly_title: 'Essential Energy',
        state: 'NSW',
        type: 'electricity',
        includes: [
          /^(NAAA[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(NBBB[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(NDDD[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(NFFF[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(4001\d{6})$/,
          /^(4508\d{6})$/,
          /^(4204\d{6})$/,
          /^(4407\d{6})$/
        ],
        excludes: [
        ]
      },
      'ENERGYAP' => {
        title: 'Ausgrid',
        friendly_title: 'Ausgrid',
        state: 'NSW',
        type: 'electricity',
        includes: [
          /^(NCCC[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(410[234]\d{6})$/
        ],
        excludes: [
        ]
      },
      'INTEGP' => {
        title: 'Endeavour Energy',
        friendly_title: 'Endeavour Energy',
        state: 'NSW',
        type: 'electricity',
        includes: [
          /^(NEEE[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(431\d{7})$/
        ],
        excludes: [
        ]
      },
      'TRANSGP' => {
        title: 'TransGrid',
        friendly_title: 'TransGrid',
        state: 'NSW',
        type: 'electricity',
        includes: [
          /^(NTTT[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(460810[0-8]\d{3})$/
        ],
        excludes: [
        ]
      },
      'SNOWY' => {
        title: 'Snowy Hydro Ltd',
        friendly_title: 'Snowy Hydro',
        state: 'NSW',
        type: 'electricity',
        includes: [
          /^(4708109\d{3})$/
        ],
        excludes: [
        ]
      },
      'NT_RESERVED' => {
        title: 'Northern Territory Reserved Block',
        friendly_title: 'Northern Territory Reserved Block',
        state: 'NT',
        type: 'electricity',
        includes: [
          /^(250\d{7})$/
        ],
        excludes: [
        ]
      },
      'ERGONETP' => {
        title: 'Ergon Energy Corporation',
        friendly_title: 'Ergon Energy',
        state: 'QLD',
        type: 'electricity',
        includes: [
          /^(QAAA[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(QCCC[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(QDDD[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(QEEE[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(QFFF[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(QGGG[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(30\d{8})$/
        ],
        excludes: [
        ]
      },
      'ENERGEXP' => {
        title: 'ENERGEX Limited',
        friendly_title: 'Energex',
        state: 'QLD',
        type: 'electricity',
        includes: [
          /^(QB\d{2}[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(31\d{8})$/
        ],
        excludes: [
        ]
      },
      'PLINKP' => {
        title: 'Qld Electricity Transmission Corp (Powerlink)',
        friendly_title: 'Powerlink',
        state: 'QLD',
        type: 'electricity',
        includes: [
          /^(Q[A-HJ-NP-Z\d]{3}W[A-HJ-NP-Z\d]{5})$/,
          /^(320200\d{4})$/
        ],
        excludes: [
        ]
      },
      'UMPLP' => {
        title: 'SA Power Networks',
        friendly_title: 'SA Power Networks',
        state: 'SA',
        type: 'electricity',
        includes: [
          /^(SAAA[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(SASMPL[\d]{4})$/,
          /^(200[12]\d{6})$/
        ],
        excludes: [
        ]
      },
      'ETSATP' => {
        title: 'ElectraNet SA',
        friendly_title: 'ElectraNet SA',
        state: 'SA',
        type: 'electricity',
        includes: [
          /^(S[A-HJ-NP-Z\d]{3}W[A-HJ-NP-Z\d]{5})$/,
          /^(210200\d{4})$/
        ],
        excludes: [
        ]
      },
      'AURORAP' => {
        title: 'TasNetworks',
        friendly_title: 'TasNetworks',
        state: 'TAS',
        type: 'electricity',
        includes: [
          /^(T000000(([0-4]\d{3})|(500[01])))$/,
          /^(8000\d{6})$/,
          /^(8590[23]\d{5})$/
        ],
        excludes: [
        ]
      },
      'TRANSEND' => {
        title: 'TasNetworks',
        friendly_title: 'TasNetworks',
        state: 'TAS',
        type: 'electricity',
        includes: [
          /^(T[A-HJ-NP-Z\d]{3}W[A-HJ-NP-Z\d]{5})$/
        ],
        excludes: [
        ]
      },
      'CITIPP' => {
        title: 'CitiPower',
        friendly_title: 'CitiPower',
        state: 'VIC',
        type: 'electricity',
        includes: [
          /^(VAAA[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(610[23]\d{6})$/
        ],
        excludes: [
        ]
      },
      'EASTERN' => {
        title: 'SP AusNet',
        friendly_title: 'SP AusNet DNSP',
        state: 'VIC',
        type: 'electricity',
        includes: [
          /^(VBBB[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(630[56]\d{6})$/
        ],
        excludes: [
        ]
      },
      'POWCP' => {
        title: 'PowerCor Australia',
        friendly_title: 'PowerCor',
        state: 'VIC',
        type: 'electricity',
        includes: [
          /^(VCCC[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(620[34]\d{6})$/
        ],
        excludes: [
        ]
      },
      'SOLARISP' => {
        title: 'Jemena  Electricity Networks (VIC)',
        friendly_title: 'Jemena',
        state: 'VIC',
        type: 'electricity',
        includes: [
          /^(VDDD[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(6001\d{6})$/
        ],
        excludes: [
        ]
      },
      'UNITED' => {
        title: 'United Energy Distribution',
        friendly_title: 'United Energy',
        state: 'VIC',
        type: 'electricity',
        includes: [
          /^(VEEE[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(640[78]\d{6})$/
        ],
        excludes: [
        ]
      },
      'GPUPP' => {
        title: 'SP AusNet TNSP',
        friendly_title: 'SP AusNet TNSP',
        state: 'VIC',
        type: 'electricity',
        includes: [
          /^(V[A-HJ-NP-Z\d]{3}W[A-HJ-NP-Z\d]{5})$/,
          /^(650900\d{4})$/
        ],
        excludes: [
        ]
      },
      'WESTERNPOWER' => {
        title: 'Western Power',
        friendly_title: 'Western Power',
        state: 'WA',
        type: 'electricity',
        includes: [
          /^(WAAA[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(800[1-9]\d{6})$/,
          /^(801\d{7})$/,
          /^(8020\d{6})$/
        ],
        excludes: [
        ]
      },
      'HORIZONPOWER' => {
        title: 'Horizon Power',
        friendly_title: 'Horizon Power',
        state: 'WA',
        type: 'electricity',
        includes: [
          /^(8021\d{6})$/
        ],
        excludes: [
        ]
      },
      'GAS_NSW' => {
        title: 'GAS NSW',
        friendly_title: 'GAS NSW',
        state: 'NSW',
        type: 'gas',
        includes: [
          /^(52\d{8})$/
        ],
        excludes: [
        ]
      },
      'GAS_VIC' => {
        title: 'GAS VIC',
        friendly_title: 'GAS VIC',
        state: 'VIC',
        type: 'gas',
        includes: [
          /^(53\d{8})$/
        ],
        excludes: [
        ]
      },
      'GAS_QLD' => {
        title: 'GAS QLD',
        friendly_title: 'GAS QLD',
        state: 'QLD',
        type: 'gas',
        includes: [
          /^(54\d{8})$/
        ],
        excludes: [
        ]
      },
      'GAS_SA' => {
        title: 'GAS SA',
        friendly_title: 'GAS SA',
        state: 'SA',
        type: 'gas',
        includes: [
          /^(55\d{8})$/
        ],
        excludes: [
        ]
      },
      'GAS_WA' => {
        title: 'GAS WA',
        friendly_title: 'GAS WA',
        state: 'WA',
        type: 'gas',
        includes: [
          /^(56\d{8})$/
        ],
        excludes: [
        ]
      },
      'GAS_TAS' => {
        title: 'GAS TAS',
        friendly_title: 'GAS TAS',
        state: 'TAS',
        type: 'gas',
        includes: [
          /^(57\d{8})$/
        ],
        excludes: [
        ]
      },
      'FEDAIRPORTS' => {
        title: 'Federal Airports Corporation (Sydney Airport)',
        friendly_title: 'Sydney Airport',
        state: 'NSW',
        type: 'electricity',
        includes: [
          /^(NJJJNR[A-HJ-NP-Z\d]{4})$/
        ],
        excludes: [
        ]
      },
      'EXEMPTNETWORKS' => {
        title: 'Exempt Networks - various',
        friendly_title: 'Exempt Networks - various',
        state: '',
        type: 'electricity',
        includes: [
          /^(NKKK[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(7102\d{6})$/
        ],
        excludes: [
        ]
      },
      'AEMORESERVED' => {
        title: 'AEMO Reserved',
        friendly_title: 'AEMO Reserved',
        state: '',
        type: 'electricity',
        includes: [
          /^(880[1-5]\d{6})$/,
          /^(9\d{9})$/
        ],
        excludes: [
        ]
      }
    }.freeze
    # Transmission Node Identifier Codes are loaded from a json file
    #  Obtained from http://www.nemweb.com.au/
    #
    #  See /lib/data for further data manipulation required
    TNI_CODES = JSON.parse(File.read(File.join(File.dirname(__FILE__), '..', 'data', 'aemo-tni.json'))).freeze
    # Distribution Loss Factor Codes are loaded from a json file
    #  Obtained from MSATS, matching to DNSP from file http://www.aemo.com.au/Electricity/Market-Operations/Loss-Factors-and-Regional-Boundaries/~/media/Files/Other/loss% 20factors/DLF_FINAL_V2_2014_2015.ashx
    #  Last accessed 2015-02-06
    #  See /lib/data for further data manipulation required
    DLF_CODES = JSON.parse(File.read(File.join(File.dirname(__FILE__), '..', 'data', 'aemo-dlf.json'))).freeze

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

    attr_accessor :nmi, :msats_detail, :tni, :dlf, :customer_classification_code, :customer_threshold_code, :jurisdiction_code, :classification_code, :status, :address, :meters, :roles, :data_streams

    # Initialize a NMI file
    #
    # @param [String] nmi the National Meter Identifier (NMI)
    # @param [Hash] options a hash of options
    # @option options [Hash] :msats_detail MSATS details as per #parse_msats_detail requirements
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
        @address                      = @msats_detail['MasterData']['Address']
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
      @data_streams.select { |x| x.status == status.to_s }
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

    # A function to validate the NMI provided
    #
    # @param [String] nmi the nmi to be checked
    # @return [Boolean] whether or not the nmi is valid
    def self.valid_nmi?(nmi)
      ((nmi.length == 10) && !nmi.match(/^([A-HJ-NP-Z\d]{10})/).nil?)
    end

    # A function to calculate the checksum value for a given National Meter Identifier
    #
    # @param [String] nmi the NMI to check the checksum against
    # @param [Integer] checksum_value the checksum value to check against the current National Meter Identifier's checksum value
    # @return [Boolean] whether or not the checksum is valid
    def self.valid_checksum?(nmi, checksum_value)
      nmi = AEMO::NMI.new(nmi)
      nmi.valid_checksum?(checksum_value)
    end

    # Find the Network for a given NMI
    #
    # @param [String] nmi NMI
    # @returns [Hash] The Network information
    def self.network(nmi)
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
                        .reject { |x| start > DateTime.parse(x['finish']) || finish < DateTime.parse(x['start']) }
      return nil if possible_values.empty?
      possible_values.map { |x| x['mlf_data']['loss_factors'] }
    end
  end
end
