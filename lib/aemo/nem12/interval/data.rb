module AEMO
  class NEM12
    class Interval
      # [AEMO::NEM12::Interval::Data]
      # Record Indicator: 300
      #
      # @author Joel Courtney
      # @abstract
      # @since 0.2.0
      class Data
        class << self
          # Parses a 300 record (aka AEMO::NEM12::Interval::Data)
          #
          # @param [String] line A single line in string format
          # @return [Array of hashes] the line parsed into a hash of information
          def parse_csv(line, options = {})
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
        end
      end
    end
  end
end
