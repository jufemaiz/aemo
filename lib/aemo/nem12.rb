# frozen_string_literal: true

require 'csv'
require 'time'

require_relative 'nem12/data_stream_suffix'
require_relative 'nem12/quality_method'
require_relative 'nem12/reason_codes'
require_relative 'nem12/record_indicators'
require_relative 'nem12/transaction_code_flags'
require_relative 'nem12/unit_of_measurement'

module AEMO
  # Namespace for classes and modules that handle AEMO Gem NEM12 interactions
  # @since 0.1.4
  class NEM12
    @file_contents    = nil
    @header           = nil
    @nmi_data_details = []

    @nmi              = nil
    @data_details     = []
    @interval_data    = []
    @interval_events  = []

    attr_reader   :data_details, :interval_data, :interval_events
    attr_accessor :file_contents, :header, :nmi_data_details, :nmi

    # Initialize a NEM12 file
    # @param [string] nmi
    # @param [Hash] options
    def initialize(nmi, options = {})
      @nmi              = AEMO::NMI.new(nmi) unless nmi.empty?
      @data_details     = []
      @interval_data    = []
      @interval_events  = []
      options.each_key do |key|
        send 'key=', options[key]
      end
    end

    # Returns the NMI Identifier or nil
    def nmi_identifier
      @nmi.nil? ? nil : @nmi.nmi
    end

    # Parses the header record
    # @param [String] line A single line in string format
    # @param [Hash] options
    # @return [Hash] the line parsed into a hash of information
    def self.parse_nem12_100(line, options = {})
      csv = line.parse_csv

      raise ArgumentError, 'RecordIndicator is not 100'     if csv[0] != '100'
      raise ArgumentError, 'VersionHeader is not NEM12'     if csv[1] != 'NEM12'
      raise ArgumentError, 'Time is not valid' if options[:strict] && (csv[2].match(/\d{12}/).nil? || csv[2] != Time.parse("#{csv[2]}00").strftime('%Y%m%d%H%M'))
      raise ArgumentError, 'FromParticipant is not valid'  if csv[3].match(/.{1,10}/).nil?
      raise ArgumentError, 'ToParticipant is not valid'    if csv[4].match(/.{1,10}/).nil?

      {
        record_indicator: csv[0].to_i,
        version_header:   csv[1],
        datetime:         Time.parse("#{csv[2]}+1000"),
        from_participant: csv[3],
        to_participant:   csv[4]
      }
    end

    # Parses the NMI Data Details
    # @param [String] line A single line in string format
    # @param [Hash] options
    # @return [Hash] the line parsed into a hash of information
    def parse_nem12_200(line, options = {})
      csv = line.parse_csv

      raise ArgumentError, 'RecordIndicator is not 200'     if csv[0] != '200'
      raise ArgumentError, 'NMI is not valid'               unless AEMO::NMI.valid_nmi?(csv[1])
      raise ArgumentError, 'NMIConfiguration is not valid' if options[:strict] && (csv[2].nil? || csv[2].match(/.{1,240}/).nil?)
      raise ArgumentError, 'RegisterID is not valid' if !csv[3].nil? && csv[3].match(/.{1,10}/).nil?
      raise ArgumentError, 'NMISuffix is not valid' if csv[4].nil? || csv[4].match(/[A-HJ-NP-Z][1-9A-HJ-NP-Z]/).nil?
      raise ArgumentError, 'MDMDataStreamIdentifier is not valid' if !csv[5].nil? && !csv[5].empty? && !csv[5].match(/^\s*$/) && csv[5].match(/[A-Z0-9]{2}/).nil?
      raise ArgumentError, 'MeterSerialNumber is not valid' if !csv[6].nil? && !csv[6].empty? && !csv[6].match(/^\s*$/) && csv[6].match(/[A-Z0-9]{2}/).nil?
      raise ArgumentError, 'UOM is not valid' if csv[7].nil? || csv[7].upcase.match(/[A-Z0-9]{2}/).nil?
      raise ArgumentError, 'UOM is not valid'               unless UOM.keys.map(&:upcase).include?(csv[7].upcase)
      raise ArgumentError, 'IntervalLength is not valid'    unless %w[1 5 10 15 30].include?(csv[8])
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
        meter_serial_number: csv[6],
        uom: csv[7].upcase,
        interval_length: csv[8].to_i,
        next_scheduled_read_date: csv[9]
      }
    end

    # @param [String] line A single line in string format
    # @param [Hash] options
    # @return [Array of hashes] the line parsed into a hash of information
    def parse_nem12_300(line, options = {})
      csv = line.parse_csv
      raise TypeError, 'Expected NMI Data Details to exist with IntervalLength specified' if @data_details.last.nil? || @data_details.last[:interval_length].nil?

      # ref: AEMO's MDFF Spec NEM12 and NEM13 v1.01 (2014-05-14)
      record_fixed_fields = %w[RecordIndicator IntervalDate QualityMethod ReasonCode ReasonDescription UpdateDatetime MSATSLoadDateTime]
      number_of_intervals = 1440 / @data_details.last[:interval_length]
      raise TypeError, 'Invalid record length' if csv.length != record_fixed_fields.length + number_of_intervals

      intervals_offset = number_of_intervals + 2

      raise ArgumentError, 'RecordIndicator is not 300' if csv[0] != '300'
      raise ArgumentError, 'IntervalDate is not valid' if csv[1].match(/\d{8}/).nil? || csv[1] != Time.parse(csv[1].to_s).strftime('%Y%m%d')
      (2..(number_of_intervals + 1)).each do |i|
        raise ArgumentError, "Interval number #{i - 1} is not valid" if csv[i].nil? || csv[i].match(/\d+(\.\d+)?/).nil?
      end
      raise ArgumentError, 'QualityMethod is not valid' unless csv[intervals_offset + 0].class == String
      raise ArgumentError, 'QualityMethod does not have valid length' unless [1, 3].include?(csv[intervals_offset + 0].length)
      raise ArgumentError, 'QualityMethod does not have valid QualityFlag' unless QUALITY_FLAGS.keys.include?(csv[intervals_offset + 0][0])
      unless %w[A N V].include?(csv[intervals_offset + 0][0])
        raise ArgumentError, 'QualityMethod does not have valid length' unless csv[intervals_offset + 0].length == 3
        raise ArgumentError, 'QualityMethod does not have valid MethodFlag' unless METHOD_FLAGS.keys.include?(csv[intervals_offset + 0][1..2].to_i)
      end
      unless %w[A N E].include?(csv[intervals_offset + 0][0])
        raise ArgumentError, 'ReasonCode is not valid' unless REASON_CODES.keys.include?(csv[intervals_offset + 1].to_i)
      end
      if !csv[intervals_offset + 1].nil? && csv[intervals_offset + 1].to_i.zero?
        raise ArgumentError, 'ReasonDescription is not valid' unless csv[intervals_offset + 2].class == String && !csv[intervals_offset + 2].empty?
      end
      if options[:strict]
        if csv[intervals_offset + 3].match(/\d{14}/).nil? || csv[intervals_offset + 3] != Time.parse(csv[intervals_offset + 3].to_s).strftime('%Y%m%d%H%M%S')
          raise ArgumentError, 'UpdateDateTime is not valid'
        end
        if !csv[intervals_offset + 4].blank? && csv[intervals_offset + 4].match(/\d{14}/).nil? || !csv[intervals_offset + 4].blank? && csv[intervals_offset + 4] != Time.parse(csv[intervals_offset + 4].to_s).strftime('%Y%m%d%H%M%S')
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
        flag[:reason_code] = csv[intervals_offset + 1].to_i unless csv[intervals_offset + 1].nil?
      end

      # Deal with updated_at & msats_load_at
      updated_at = nil
      msats_load_at = nil

      if options[:strict]
        updated_at = Time.parse(csv[intervals_offset + 3]) unless csv[intervals_offset + 3].blank?
        msats_load_at = Time.parse(csv[intervals_offset + 4]) unless csv[intervals_offset + 4].blank?
      end

      base_interval = {
        data_details: @data_details.last,
        datetime: Time.parse("#{csv[1]}000000+1000"),
        value: nil,
        flag: flag,
        updated_at: updated_at,
        msats_load_at: msats_load_at
      }

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
    # @param [Hash] options
    # @return [Hash] the line parsed into a hash of information
    def parse_nem12_400(line, options = {})
      csv = line.parse_csv
      raise ArgumentError, 'RecordIndicator is not 400'     if csv[0] != '400'
      raise ArgumentError, 'StartInterval is not valid'     if csv[1].nil? || csv[1].match(/^\d+$/).nil?
      raise ArgumentError, 'EndInterval is not valid'       if csv[2].nil? || csv[2].match(/^\d+$/).nil?
      raise ArgumentError, 'QualityMethod is not valid'     if csv[3].nil? || csv[3].match(/^([AN]|([AEFNSV]\d{2}))$/).nil?
      # raise ArgumentError, 'ReasonCode is not valid'        if (csv[4].nil? && csv[3].match(/^ANE/)) || csv[4].match(/^\d{3}?$/) || csv[3].match(/^ANE/)
      # raise ArgumentError, 'ReasonDescription is not valid' if (csv[4].nil? && csv[3].match(/^ANE/)) || ( csv[5].match(/^$/) && csv[4].match(/^0$/) )

      interval_events = []

      # Only need to update flags for EFSV
      unless %w[A N].include? csv[3]
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
          flag[:reason_code] = interval_event[:reason_code] unless interval_event[:reason_code].nil?
          # Update with flag details
          @interval_data[interval_start_point + (i - 1)][:flag] = flag
        end
        @interval_events += interval_events
      end
      interval_events
    end

    # What even is a 500 row?
    #
    # @param [String] line A single line in string format
    # @param [Hash] _options
    # @return [Hash] the line parsed into a hash of information
    def parse_nem12_500(_line, _options = {}); end

    # 900 is the last row a NEM12 should see...
    #
    # @param [String] line A single line in string format
    # @param [Hash] _options
    # @return [Hash] the line parsed into a hash of information
    def parse_nem12_900(_line, _options = {}); end

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
      headers = %w[nmi suffix units datetime value flags]
      ([headers] + to_a.map do |row|
        row[3] = row[3].strftime('%Y%m%d%H%M%S%z')
        row
      end).map do |row|
        row.join(', ')
      end.join("\n")
    end

    # @param [String] path_to_file the path to a file
    # @return [Array<AEMO::NEM12>] NEM12 object
    def self.parse_nem12_file(path_to_file, strict = true)
      parse_nem12(File.read(path_to_file), strict)
    end

    # @param [String] contents the path to a file
    # @param [Boolean] strict
    # @return [Array<AEMO::NEM12>] An array of NEM12 objects
    def self.parse_nem12(contents, strict = true)
      file_contents = contents.tr("\r", "\n").tr("\n\n", "\n").split("\n").delete_if(&:empty?)
      # nothing to further process
      return [] if file_contents.empty?

      raise ArgumentError, 'First row should be have a RecordIndicator of 100 and be of type Header Record' unless file_contents.first.parse_csv[0] == '100'

      nem12s = []
      AEMO::NEM12.parse_nem12_100(file_contents.first, strict: strict)
      file_contents.each do |line|
        case line[0..2].to_i
        when 200
          nem12s << AEMO::NEM12.new('')
          nem12s.last.parse_nem12_200(line, strict: strict)
        when 300
          nem12s.last.parse_nem12_300(line, strict: strict)
        when 400
          nem12s.last.parse_nem12_400(line, strict: strict)
          # when 500
          #   nem12s.last.parse_nem12_500(line, strict: strict)
          # when 900
          #   nem12s.last.parse_nem12_900(line, strict: strict)
        end
      end
      # Return the array of NEM12 groups
      nem12s
    end
  end
end
