# encoding: UTF-8

module AEMO
  class NMI
    # [AEMO::NMI::UnitOfMeasurement]
    #
    # @author Joel Courtney
    # @abstract
    # @since 0.2.0
    # @attr [String] unit_of_measurement DateTime that the file was created at
    class UnitOfMeasurement
      UNITS_OF_MEASUREMENT = {
        'WH'    => { abbreviation: 'Wh', title: 'Watt Hour' },
        'W'     => { abbreviation: 'W', title: 'Watt' },
        'VARH'  => { abbreviation: 'VArh', title: 'Volt Ampere Reactive Hour' },
        'VAR'   => { abbreviation: 'VAr', title: 'Volt Ampere Reactive' },
        'VAH'   => { abbreviation: 'VAh', title: 'Volt Ampere Hour' },
        'VA'    => { abbreviation: 'VA', title: 'Volt Ampere' },
        'V'     => { abbreviation: 'V', title: 'Volt' },
        'A'     => { abbreviation: 'A', title: 'Ampere' },
        'PF'    => { abbreviation: 'pf', title: 'Power Factor' }
      }.freeze

      PREFIXES = {
        'G' => { multiplier: 1e9, title: 'Giga', abbreviation: 'G' },
        'M' => { multiplier: 1e6, title: 'Mega', abbreviation: 'M' },
        'K' => { multiplier: 1e3, title: 'Kilo', abbreviation: 'k' },
        ''  => { multiplier: 1e0, title: '', abbreviation: '' }
      }.freeze

      @unit_abbreviation = nil
      @unit_title = nil
      @prefix_abbreviation = nil
      @prefix_title = nil
      @prefix_multiplier = nil

      attr_reader :unit_abbreviation, :prefix_abbreviation, :prefix_multiplier

      class << self
        # Multiplier for a given prefix
        #
        # @param [String] prefix_abbreviation
        # @return [Number]
        def multiplier(prefix_abbreviation)
          raise ArgumentError, 'Invalid Prefix Abbreviation' unless PREFIXES.keys.include?(prefix_abbreviation)
          PREFIXES[prefix_abbreviation][:multiplier]
        end

        # Converts a value from one prefix to another
        #
        # @param [Number] value
        # @param [String] old_prefix_abbreviation
        # @param [String] new_prefix_abbreviation
        # @return [Number]
        def convert(value, old_prefix_abbreviation, new_prefix_abbreviation)
          (value * multiplier(old_prefix_abbreviation)) / multiplier(new_prefix_abbreviation)
        end

        # Validates a Unit of Measurement
        #
        # @param [String] unit_of_measurement
        # @return [Boolean]
        def valid?(unit_of_measurement)
          return false unless unit_of_measurement.is_a?(String)
          unit_of_measurement.upcase!
          matches = unit_of_measurement.match(/^([KM])?(.+?)$/)
          return false unless PREFIXES.keys.include?(matches[1].to_s)
          return false unless UNITS_OF_MEASUREMENT.keys.include?(matches[2])
          true
        end
      end

      # Creates a new instance of AEMO::NMI::UnitOfMeasurement
      #
      # @param [String] unit_of_measurement the unit of measurement
      # @return [AEMO::NMI::UnitOfMeasurement]
      def initialize(unit_of_measurement)
        raise ArgumentError, 'Unit of Measurement is not a String' unless unit_of_measurement.is_a?(String)
        unit_of_measurement.upcase!
        matches = unit_of_measurement.match(/^([KM])?(.+?)$/)
        raise ArgumentError, 'Invalid Prefix' unless PREFIXES.keys.include?(matches[1].to_s)
        raise ArgumentError, 'Invalid Unit of Measurement' unless UNITS_OF_MEASUREMENT.keys.include?(matches[2])

        unit = UNITS_OF_MEASUREMENT[matches[2]]
        @unit_abbreviation = unit[:abbreviation]
        @unit_title = unit[:title]

        prefix = PREFIXES[matches[1].to_s]
        @prefix_abbreviation = prefix[:abbreviation]
        @prefix_title = prefix[:title]
        @prefix_multiplier = prefix[:multiplier]

        self
      end

      # Converts a value from one prefix to another
      #
      # @param [Number] value
      # @param [String, AEMO::NMI::UnitOfMeasurement] new_prefix
      # @return [Number]
      def convert_to(value, new_prefix)
        new_prefix_abbreviation = if new_prefix.is_a?(String)
                                    new_prefix
                                  elsif new_prefix.is_a?(AEMO::NMI::UnitOfMeasurement)
                                    new_prefix.prefix_abbreviation
                                  end

        UnitOfMeasurement.convert(value, @prefix_abbreviation.upcase, new_prefix_abbreviation.upcase)
      end

      # Combines prefix and unit title
      #
      # @return [String]
      def title
        title = if @prefix_title.empty?
                  @unit_title
                else
                  @unit_title[0, 1].downcase + @unit_title[1..-1]
                end
        "#{@prefix_title}#{title}"
      end

      # Returns the combined abbreviation
      #
      # @return [String]
      def abbreviation
        @prefix_abbreviation + @unit_abbreviation
      end
    end
  end
end
