# encoding: UTF-8
require 'csv'
require 'time'

require_relative 'nem12/header'
require_relative 'nem12/nmi_data_details'
require_relative 'nem12/interval'
require_relative 'nem12/b2b_details'

module AEMO
  # Namespace for classes and modules that handle AEMO Gem NEM12 interactions
  # @since 0.1.4
  class NEM12
    # As per AEMO NEM12 Specification
    # http://www.aemo.com.au/Consultations/National-Electricity-Market/Open/~/media/
    # Files/Other/consultations/nem/Meter% 20Data% 20File% 20Format% 20Specification% 20
    # NEM12_NEM13/MDFF_Specification_NEM12_NEM13_Final_v102_clean.ashx

    RECORD_INDICATORS = {
      100 => 'Header',
      200 => 'NMI Data Details',
      300 => 'Interval Data',
      400 => 'Interval Event',
      500 => 'B2B Details',
      900 => 'End'
    }.freeze

    TRANSACTION_CODE_FLAGS = {
      'A' => 'Alteration',
      'C' => 'Meter Reconfiguration',
      'G' => 'Re-energisation',
      'D' => 'De-energisation',
      'E' => 'Forward Estimate',
      'N' => 'Normal Read',
      'O' => 'Other',
      'S' => 'Special Read',
      'R' => 'Removal of Meter'
    }.freeze

    UOM = {
      'MWh'   => { name: 'Megawatt Hour', multiplier: 1e6 },
      'kWh'   => { name: 'Kilowatt Hour', multiplier: 1e3 },
      'Wh'    => { name: 'Watt Hour', multiplier: 1 },
      'MW'    => { name: 'Megawatt', multiplier: 1e6 },
      'kW'    => { name: 'Kilowatt', multiplier: 1e3 },
      'W'     => { name: 'Watt', multiplier: 1 },
      'MVArh' => { name: 'Megavolt Ampere Reactive Hour', multiplier: 1e6 },
      'kVArh' => { name: 'Kilovolt Ampere Reactive Hour', multiplier: 1e3 },
      'VArh'  => { name: 'Volt Ampere Reactive Hour', multiplier: 1 },
      'MVAr'  => { name: 'Megavolt Ampere Reactive', multiplier: 1e6 },
      'kVAr'  => { name: 'Kilovolt Ampere Reactive', multiplier: 1e3 },
      'VAr'   => { name: 'Volt Ampere Reactive', multiplier: 1 },
      'MVAh'  => { name: 'Megavolt Ampere Hour', multiplier: 1e6 },
      'kVAh'  => { name: 'Kilovolt Ampere Hour', multiplier: 1e3 },
      'VAh'   => { name: 'Volt Ampere Hour', multiplier: 1 },
      'MVA'   => { name: 'Megavolt Ampere', multiplier: 1e6 },
      'kVA'   => { name: 'Kilovolt Ampere', multiplier: 1e3 },
      'VA'    => { name: 'Volt Ampere', multiplier: 1 },
      'kV'    => { name: 'Kilovolt', multiplier: 1e3 },
      'V'     => { name: 'Volt', multiplier: 1 },
      'kA'    => { name: 'Kiloampere', multiplier: 1e3 },
      'A'     => { name: 'Ampere', multiplier: 1 },
      'pf'    => { name: 'Power Factor', multiplier: 1 }
    }.freeze

    UOM_NON_SPEC_MAPPING = {
      'MWH'   => 'MWh',
      'KWH'   => 'kWh',
      'WH'    => 'Wh',
      'MW'    => 'MW',
      'KW'    => 'kW',
      'W'     => 'W',
      'MVARH' => 'MVArh',
      'KVARH' => 'kVArh',
      'VARH'  => 'VArh',
      'MVAR'  => 'MVAr',
      'KVAR'  => 'kVAr',
      'VAR'   => 'VAr',
      'MVAH'  => 'MVAh',
      'KVAH'  => 'kVAh',
      'VAH'   => 'VAh',
      'MVA'   => 'MVA',
      'KVA'   => 'kVA',
      'VA'    => 'VA',
      'KV'    => 'kV',
      'V'     => 'V',
      'KA'    => 'kA',
      'A'     => 'A',
      'PF'    => 'pf'
    }.freeze

    QUALITY_FLAGS = {
      'A'     => 'Actual Data',
      'E'     => 'Forward Estimated Data',
      'F'     => 'Final Substituted Data',
      'N'     => 'Null Data',
      'S'     => 'Substituted Data',
      'V'     => 'Variable Data'
    }.freeze

    METHOD_FLAGS = {
      11 => { type: %w(SUB), installation_type: [1, 2, 3, 4], short_descriptor: 'Check', description: '' },
      12 => { type: %w(SUB), installation_type: [1, 2, 3, 4], short_descriptor: 'Calculated', description: '' },
      13 => { type: %w(SUB), installation_type: [1, 2, 3, 4], short_descriptor: 'SCADA', description: '' },
      14 => { type: %w(SUB), installation_type: [1, 2, 3, 4], short_descriptor: 'Like Day', description: '' },
      15 => { type: %w(SUB), installation_type: [1, 2, 3, 4], short_descriptor: 'Average Like Day', description: '' },
      16 => { type: %w(SUB), installation_type: [1, 2, 3, 4], short_descriptor: 'Agreed', description: '' },
      17 => { type: %w(SUB), installation_type: [1, 2, 3, 4], short_descriptor: 'Linear', description: '' },
      18 => { type: %w(SUB), installation_type: [1, 2, 3, 4], short_descriptor: 'Alternate', description: '' },
      19 => { type: %w(SUB), installation_type: [1, 2, 3, 4], short_descriptor: 'Zero', description: '' },
      51 => { type: %w(EST SUB), installation_type: 5, short_descriptor: 'Previous Year', description: '' },
      52 => { type: %w(EST SUB), installation_type: 5, short_descriptor: 'Previous Read', description: '' },
      53 => { type: %w(SUB), installation_type: 5, short_descriptor: 'Revision', description: '' },
      54 => { type: %w(SUB), installation_type: 5, short_descriptor: 'Linear', description: '' },
      55 => { type: %w(SUB), installation_type: 5, short_descriptor: 'Agreed', description: '' },
      56 => { type: %w(EST SUB), installation_type: 5, short_descriptor: 'Prior to First Read - Agreed', description: '' },
      57 => { type: %w(EST SUB), installation_type: 5, short_descriptor: 'Customer Class', description: '' },
      58 => { type: %w(EST SUB), installation_type: 5, short_descriptor: 'Zero', description: '' },
      61 => { type: %w(EST SUB), installation_type: 6, short_descriptor: 'Previous Year', description: '' },
      62 => { type: %w(EST SUB), installation_type: 6, short_descriptor: 'Previous Read', description: '' },
      63 => { type: %w(EST SUB), installation_type: 6, short_descriptor: 'Customer Class', description: '' },
      64 => { type: %w(SUB), installation_type: 6, short_descriptor: 'Agreed', description: '' },
      65 => { type: %w(EST), installation_type: 6, short_descriptor: 'ADL', description: '' },
      66 => { type: %w(SUB), installation_type: 6, short_descriptor: 'Revision', description: '' },
      67 => { type: %w(SUB), installation_type: 6, short_descriptor: 'Customer Read', description: '' },
      68 => { type: %w(EST SUB), installation_type: 6, short_descriptor: 'Zero', description: '' },
      71 => { type: %w(SUB), installation_type: 7, short_descriptor: 'Recalculation', description: '' },
      72 => { type: %w(SUB), installation_type: 7, short_descriptor: 'Revised Table', description: '' },
      73 => { type: %w(SUB), installation_type: 7, short_descriptor: 'Revised Algorithm', description: '' },
      74 => { type: %w(SUB), installation_type: 7, short_descriptor: 'Agreed', description: '' },
      75 => { type: %w(EST), installation_type: 7, short_descriptor: 'Existing Table', description: '' }
    }.freeze

    REASON_CODES = {
      0 => 'Free Text Description',
      1 => 'Meter/Equipment Changed',
      2 => 'Extreme Weather/Wet',
      3 => 'Quarantine',
      4 => 'Savage Dog',
      5 => 'Meter/Equipment Changed',
      6 => 'Extreme Weather/Wet',
      7 => 'Unable To Locate Meter',
      8 => 'Vacant Premise',
      9 => 'Meter/Equipment Changed',
      10 => 'Lock Damaged/Seized',
      11 => 'In Wrong Walk',
      12 => 'Locked Premises',
      13 => 'Locked Gate',
      14 => 'Locked Meter Box',
      15 => 'Access - Overgrown',
      16 => 'Noxious Weeds',
      17 => 'Unsafe Equipment/Location',
      18 => 'Read Below Previous',
      19 => 'Consumer Wanted',
      20 => 'Damaged Equipment/Panel',
      21 => 'Switched Off',
      22 => 'Meter/Equipment Seals Missing',
      23 => 'Meter/Equipment Seals Missing',
      24 => 'Meter/Equipment Seals Missing',
      25 => 'Meter/Equipment Seals Missing',
      26 => 'Meter/Equipment Seals Missing',
      27 => 'Meter/Equipment Seals Missing',
      28 => 'Damaged Equipment/Panel',
      29 => 'Relay Faulty/Damaged',
      30 => 'Meter Stop Switch On',
      31 => 'Meter/Equipment Seals Missing',
      32 => 'Damaged Equipment/Panel',
      33 => 'Relay Faulty/Damaged',
      34 => 'Meter Not In Handheld',
      35 => 'Timeswitch Faulty/Reset Required',
      36 => 'Meter High/Ladder Required',
      37 => 'Meter High/Ladder Required',
      38 => 'Unsafe Equipment/Location',
      39 => 'Reverse Energy Observed',
      40 => 'Timeswitch Faulty/Reset Required',
      41 => 'Faulty Equipment Display/Dials',
      42 => 'Faulty Equipment Display/Dials',
      43 => 'Power Outage',
      44 => 'Unsafe Equipment/Location',
      45 => 'Readings Failed To Validate',
      46 => 'Extreme Weather/Hot',
      47 => 'Refused Access',
      48 => 'Timeswitch Faulty/Reset Required',
      49 => 'Wet Paint',
      50 => 'Wrong Tariff',
      51 => 'Installation Demolished',
      52 => 'Access - Blocked',
      53 => 'Bees/Wasp In Meter Box',
      54 => 'Meter Box Damaged/Faulty',
      55 => 'Faulty Equipment Display/Dials',
      56 => 'Meter Box Damaged/Faulty',
      57 => 'Timeswitch Faulty/Reset Required',
      58 => 'Meter Ok - Supply Failure',
      59 => 'Faulty Equipment Display/Dials',
      60 => 'Illegal Connection/Equipment Tampered',
      61 => 'Meter Box Damaged/Faulty',
      62 => 'Damaged Equipment/Panel',
      63 => 'Illegal Connection/Equipment Tampered',
      64 => 'Key Required',
      65 => 'Wrong Key Provided',
      66 => 'Lock Damaged/Seized',
      67 => 'Extreme Weather/Wet',
      68 => 'Zero Consumption',
      69 => 'Reading Exceeds Estimate',
      70 => 'Probe Reports Tampering',
      71 => 'Probe Read Error',
      72 => 'Meter/Equipment Changed',
      73 => 'Low Consumption',
      74 => 'High Consumption',
      75 => 'Customer Read',
      76 => 'Communications Fault',
      77 => 'Estimation Forecast',
      78 => 'Null Data',
      79 => 'Power Outage Alarm',
      80 => 'Short Interval Alarm',
      81 => 'Long Interval Alarm',
      82 => 'CRC Error',
      83 => 'RAM Checksum Error',
      84 => 'ROM Checksum Error',
      85 => 'Data Missing Alarm',
      86 => 'Clock Error Alarm',
      87 => 'Reset Occurred',
      88 => 'Watchdog Timeout Alarm',
      89 => 'Time Reset Occurred',
      90 => 'Test Mode',
      91 => 'Load Control',
      92 => 'Added Interval (Data Correction)',
      93 => 'Replaced Interval (Data Correction)',
      94 => 'Estimated Interval (Data Correction)',
      95 => 'Pulse Overflow Alarm',
      96 => 'Data Out Of Limits',
      97 => 'Excluded Data',
      98 => 'Parity Error',
      99 => 'Energy Type (Register Changed)'
    }.freeze

    DATA_STREAM_SUFFIX = {
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
      'G' => { stream: 'Master',  description: 'Power Factor', units: 'PF' },
      'H' => { stream: 'Master',  description: 'Q Metering', units: 'Qh' },
      'M' => { stream: 'Master',  description: 'Par Metering', units: 'parh' },
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
      # 'D' => { stream: 'Net',    description: 'Net', units: 'kWh' },
      # 'J' => { stream: 'Net',    description: 'Net', units: 'kVArh' }
    }.freeze

    @file_contents    = nil
    @header           = nil
    @nmi_data_details = []

    attr_accessor :nmi, :file_contents, :header, :nmi_data_details, :nmi
    attr_reader   :data_details, :interval_data, :interval_events

    class << self
      # Parses the header record
      #
      # @param [String] line A single line in string format
      # @return [Hash] the line parsed into a hash of information
      def parse_nem12_100(line, options = {})
        csv = line.parse_csv

        raise ArgumentError, 'RecordIndicator is not 100'     if csv[0] != '100'
        raise ArgumentError, 'VersionHeader is not NEM12'     if csv[1] != 'NEM12'
        if options[:strict] && (csv[2].match(/\d{12}/).nil? || csv[2] != Time.parse("#{csv[2]}00").strftime('%Y%m%d%H%M'))
          raise ArgumentError, 'DateTime is not valid'
        end
        raise ArgumentError, 'FromParticispant is not valid'  if csv[3].match(/.{1,10}/).nil?
        raise ArgumentError, 'ToParticispant is not valid'    if csv[4].match(/.{1,10}/).nil?

        {
          record_indicator: csv[0].to_i,
          version_header:   csv[1],
          datetime:         Time.parse("#{csv[2]}+1000"),
          from_participant: csv[3],
          to_participant:   csv[4]
        }
      end

      # Parses a NEM12 based file, returning an array of AEMO::NEM12 objects
      #
      # @param [String] path_to_file the path to a file
      # @return [Array<AEMO::NEM12>] An array of AEMO::NEM12 objects
      def parse_nem12_file(path_to_file, strict = false)
        parse_nem12(File.read(path_to_file), strict)
      end

      # Parses a NEM12 based string, returning an array of AEMO::NEM12 objects
      #
      # @param [String] contents the path to a file
      # @param [Boolean] strict
      # @return [Array<AEMO::NEM12>] An array of NEM12 objects
      def parse_nem12(contents, strict = false)
        file_contents = contents.tr('\r', '\n').tr('\n\n', '\n').split('\n').delete_if(&:empty?)
        raise ArgumentError, 'First row should be have a RecordIndicator of 100 and be of type Header Record' unless file_contents.first.parse_csv[0] == '100'

        nem12s = []
        AEMO::NEM12.parse_nem12_100(file_contents.first, strict: strict)
        file_contents.each do |line|
          case line[0..2].to_i
          when 200
            nem12s << AEMO::NEM12.new('')
            nem12s.last.parse_nem12_200(line)
          when 300
            nem12s.last.parse_nem12_300(line)
          when 400
            nem12s.last.parse_nem12_400(line)
          when 500
            nem12s.last.parse_nem12_500(line)
          when 900
            nem12s.last.parse_nem12_900(line)
          end
        end
        # Return the array of AEMO::NEM12 Objects
        nem12s
      end
    end

    # Initialize a NEM12 file
    def initialize(nmi, options = {})
      @nmi              = AEMO::NMI.new(nmi) unless nmi.empty?
      @data_details     = []
      @interval_data    = []
      @interval_events  = []
      options.keys.each do |key|
        send 'key=', options[key]
      end
    end

    # Returns the NMI Identifier or nil
    def nmi_identifier
      @nmi.nil? ? nil : @nmi.nmi
    end

    # Parses the NMI Data Details
    # @param [String] line A single line in string format
    # @return [Hash] the line parsed into a hash of information
    def parse_nem12_200(line, _options = {})
      csv = line.parse_csv

      raise ArgumentError, 'RecordIndicator is not 200'     if csv[0] != '200'
      raise ArgumentError, 'NMI is not valid'               unless AEMO::NMI.valid_nmi?(csv[1])
      raise ArgumentError, 'NMIConfiguration is not valid'  if csv[2].match(/.{1,240}/).nil?
      if !csv[3].nil? && csv[3].match(/.{1,10}/).nil?
        raise ArgumentError, 'RegisterID is not valid'
      end
      raise ArgumentError, 'NMISuffix is not valid' if csv[4].match(/[A-HJ-NP-Z][1-9A-HJ-NP-Z]/).nil?
      if !csv[5].nil? && !csv[5].empty? && !csv[5].match(/^\s*$/)
        raise ArgumentError, 'MDMDataStreamIdentifier is not valid' if csv[5].match(/[A-Z0-9]{2}/).nil?
      end
      if !csv[6].nil? && !csv[6].empty? && !csv[6].match(/^\s*$/)
        raise ArgumentError, 'MeterSerialNumber is not valid' if csv[6].match(/[A-Z0-9]{2}/).nil?
      end
      raise ArgumentError, 'UOM is not valid'               if csv[7].upcase.match(/[A-Z0-9]{2}/).nil?
      raise ArgumentError, 'UOM is not valid'               unless UOM.keys.map(&:upcase).include?(csv[7].upcase)
      raise ArgumentError, 'IntervalLength is not valid'    unless %w(1 5 10 15 30).include?(csv[8])
      # raise ArgumentError, 'NextScheduledReadDate is not valid' if csv[9].match(/\d{8}/).nil? || csv[9] != Time.parse('#{csv[9]}').strftime('%Y%m%d')

      @nmi = AEMO::NMI.new(csv[1])

      # Push onto the stack
      @data_details << {
        record_indicator: csv[0].to_i,
        nmi: csv[1],
        nmi_configuration: csv[2],
        register_id: csv[3],
        nmi_suffix: csv[4],
        mdm_data_streaming_identifier: csv[5],
        meter_serial_nubmer: csv[6],
        uom: csv[7].upcase,
        interval_length: csv[8].to_i,
        next_scheduled_read_date: csv[9]
      }
    end

    # @param [String] line A single line in string format
    # @return [Array of hashes] the line parsed into a hash of information
    def parse_nem12_300(line, options = {})
      csv = line.parse_csv

      raise TypeError, 'Expected NMI Data Details to exist with IntervalLength specified' if @data_details.last.nil? || @data_details.last[:interval_length].nil?
      number_of_intervals = 1440 / @data_details.last[:interval_length]
      intervals_offset = number_of_intervals + 2

      raise ArgumentError, 'RecordIndicator is not 300' if csv[0] != '300'
      raise ArgumentError, 'IntervalDate is not valid' if csv[1].match(/\d{8}/).nil? || csv[1] != Time.parse(csv[1].to_s).strftime('%Y%m%d')
      (2..(number_of_intervals + 1)).each do |i|
        raise ArgumentError, "Interval number #{i - 1} is not valid" if csv[i].match(/\d+(\.\d+)?/).nil?
      end
      raise ArgumentError, 'QualityMethod is not valid' unless csv[intervals_offset + 0].class == String
      raise ArgumentError, 'QualityMethod does not have valid length' unless [1, 3].include?(csv[intervals_offset + 0].length)
      raise ArgumentError, 'QualityMethod does not have valid QualityFlag' unless QUALITY_FLAGS.keys.include?(csv[intervals_offset + 0][0])
      unless %w(A N V).include?(csv[intervals_offset + 0][0])
        raise ArgumentError, 'QualityMethod does not have valid length' unless csv[intervals_offset + 0].length == 3
        raise ArgumentError, 'QualityMethod does not have valid MethodFlag' unless METHOD_FLAGS.keys.include?(csv[intervals_offset + 0][1..2].to_i)
      end
      unless %w(A N E).include?(csv[intervals_offset + 0][0])
        raise ArgumentError, 'ReasonCode is not valid' unless REASON_CODES.keys.include?(csv[intervals_offset + 1].to_i)
      end
      if !csv[intervals_offset + 1].nil? && csv[intervals_offset + 1].to_i == 0
        raise ArgumentError, 'ReasonDescription is not valid' unless csv[intervals_offset + 2].class == String && !csv[intervals_offset + 2].empty?
      end
      if options[:strict]
        if csv[intervals_offset + 3].match(/\d{14}/).nil? || csv[intervals_offset + 3] != Time.parse(csv[intervals_offset + 3].to_s).strftime('%Y%m%d%H%M%S')
          raise ArgumentError, 'UpdateDateTime is not valid'
        end
        if !csv[intervals_offset + 4].nil? && csv[intervals_offset + 4].match(/\d{14}/).nil? || csv[intervals_offset + 4] != Time.parse(csv[intervals_offset + 4].to_s).strftime('%Y%m%d%H%M%S')
          raise ArgumentError, 'MSATSLoadDateTime is not valid'
        end
      end

      # Deal with flags if necessary
      flag = nil
      # Based on QualityMethod and ReasonCode
      if csv[intervals_offset + 0].length == 3 || !csv[intervals_offset + 1].nil?
        flag ||= { quality_flag: nil, method_flag: nil, reason_code: nil }
        if csv[intervals_offset + 0].length == 3
          flag[:quality_flag] = csv[intervals_offset + 0][0]
          flag[:method_flag] = csv[intervals_offset + 0][1, 2].to_i
        end
        unless csv[intervals_offset + 1].nil?
          flag[:reason_code] = csv[intervals_offset + 1].to_i
        end
      end

      base_interval = { data_details: @data_details.last, datetime: Time.parse("#{csv[1]}000000+1000"), value: nil, flag: flag }

      intervals = []
      (2..(number_of_intervals + 1)).each do |i|
        interval = base_interval.dup
        interval[:datetime] += (i - 1) * interval[:data_details][:interval_length] * 60
        interval[:value] = csv[i].to_f
        intervals << interval
      end
      @interval_data += intervals
      intervals
    end

    # @param [String] line A single line in string format
    # @return [Hash] the line parsed into a hash of information
    def parse_nem12_400(line)
      csv = line.parse_csv
      raise ArgumentError, 'RecordIndicator is not 400'     if csv[0] != '400'
      raise ArgumentError, 'StartInterval is not valid'     if csv[1].match(/^\d+$/).nil?
      raise ArgumentError, 'EndInterval is not valid'       if csv[2].match(/^\d+$/).nil?
      raise ArgumentError, 'QualityMethod is not valid'     if csv[3].match(/^([AN]|([AEFNSV]\d{2}))$/).nil?
      # raise ArgumentError, 'ReasonCode is not valid'        if (csv[4].nil? && csv[3].match(/^ANE/)) || csv[4].match(/^\d{3}?$/) || csv[3].match(/^ANE/)
      # raise ArgumentError, 'ReasonDescription is not valid' if (csv[4].nil? && csv[3].match(/^ANE/)) || ( csv[5].match(/^$/) && csv[4].match(/^0$/) )

      interval_events = []

      # Only need to update flags for EFSV
      unless %w(A N).include?csv[3]
        number_of_intervals = 1440 / @data_details.last[:interval_length]
        interval_start_point = @interval_data.length - number_of_intervals

        # For each of these
        base_interval_event = { datetime: nil, quality_method: csv[3], reason_code: (csv[4].nil? ? nil : csv[4].to_i), reason_description: csv[5] }

        # Interval Numbers are 1-indexed
        ((csv[1].to_i)..(csv[2].to_i)).each do |i|
          interval_event = base_interval_event.dup
          interval_event[:datetime] = @interval_data[interval_start_point + (i - 1)][:datetime]
          interval_events << interval_event
          # Create flag details
          flag ||= { quality_flag: nil, method_flag: nil, reason_code: nil }
          unless interval_event[:quality_method].nil?
            flag[:quality_flag] = interval_event[:quality_method][0]
            flag[:method_flag] = interval_event[:quality_method][1, 2].to_i
          end
          unless interval_event[:reason_code].nil?
            flag[:reason_code] = interval_event[:reason_code]
          end
          # Update with flag details
          @interval_data[interval_start_point + (i - 1)][:flag] = flag
        end
        @interval_events += interval_events
      end
      interval_events
    end

    # @param [String] line A single line in string format
    # @return [Hash] the line parsed into a hash of information
    def parse_nem12_500(_line, _options = {})
    end

    # @param [String] line A single line in string format
    # @return [Hash] the line parsed into a hash of information
    def parse_nem12_900(_line, _options = {})
    end

    # Turns the flag to a string
    #
    # @param [Hash] flag the object of a flag
    # @return [nil, String] a hyphenated string for the flag or nil
    def flag_to_s(flag)
      flag_to_s = []
      unless flag.nil?
        flag_to_s << QUALITY_FLAGS[flag[:quality_flag]]                   unless QUALITY_FLAGS[flag[:quality_flag]].nil?
        flag_to_s << METHOD_FLAGS[flag[:method_flag]][:short_descriptor]  unless METHOD_FLAGS[flag[:method_flag]].nil?
        flag_to_s << REASON_CODES[flag[:reason_code]]                     unless REASON_CODES[flag[:reason_code]].nil?
      end
      flag_to_s.empty? ? nil : flag_to_s.join(' - ')
    end

    # @return [Array] array of a NEM12 file a given Meter + Data Stream for easy reading
    def to_a
      @interval_data.map do |d|
        [
          d[:data_details][:nmi],
          d[:data_details][:nmi_suffix].upcase,
          d[:data_details][:uom],
          d[:datetime],
          d[:value],
          flag_to_s(d[:flag])
        ]
      end
    end

    # @return [Array] CSV of a NEM12 file a given Meter + Data Stream for easy reading
    def to_csv
      headers = %w(nmi suffix units datetime value flags)
      ([headers] + to_a.map do |row|
        row[3] = row[3].strftime('%Y%m%d%H%M%S%z')
        row
      end).map do |row|
        row.join(', ')
      end.join('\n')
    end

    #
    #
    # @return [String]
    def to_json
    end

    #
    #
    # @return [String]
    def to_xml
    end

    #
    #
    # @return [String]
    def to_nem12
    end
  end
end
