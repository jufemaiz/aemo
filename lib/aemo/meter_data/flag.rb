# frozen_string_literal: true

require_relative 'flag/quality'
require_relative 'flag/method'
require_relative 'flag/reason_code'

module AEMO
  module MeterData
    # Represents a NEM12/NEM13 quality flag with validation and conversion capabilities
    # @since 0.2.0
    class Flag
      attr_reader :quality_flag, :method_flag, :reason_code

      # Initialize a new Flag instance
      #
      # @param quality_flag [String, nil] the quality flag ('A', 'E', 'F', 'N', 'S', 'V')
      # @param method_flag [Integer, nil] the method flag (11-75)
      # @param reason_code [Integer, nil] the reason code (0-99)
      # @param validate [Boolean] whether to validate the flag (default: true)
      def initialize(quality_flag: nil, method_flag: nil, reason_code: nil, validate: true)
        @quality_flag = quality_flag
        @method_flag = method_flag
        @reason_code = reason_code

        # Validate the flag if requested
        self.class.validate!(self) if validate
      end

      class << self
        # Create a Flag from a hash (backward compatibility)
        #
        # @param hash [Hash, Flag, nil] the hash or Flag instance
        # @param validate [Boolean] whether to validate the flag (default: false for backward compatibility)
        # @return [Flag, nil] a new Flag instance or nil if input is nil
        def from_hash(hash, validate: false)
          return nil if hash.nil?
          return hash if hash.is_a?(Flag)

          new(
            quality_flag: hash[:quality_flag],
            method_flag: hash[:method_flag],
            reason_code: hash[:reason_code],
            validate: validate
          )
        end

        # Create a Flag from a quality method string and reason code
        #
        # @param quality_method [String] the quality method string (e.g., 'A', 'E52', 'F11')
        # @param reason_code [String] the reason code ('0'-'99' or '')
        # @param validate [Boolean] whether to validate the flag (default: false for backward compatibility)
        # @return [Flag] a new Flag instance
        def from_quality_method_reason_code(quality_method:, reason_code:, validate: false)
          quality_flag = quality_method[0]
          method_flag = quality_method[1, 2].to_i if quality_method.length == 3
          new(
            quality_flag:,
            method_flag:,
            reason_code: reason_code.blank? ? nil : reason_code.to_i,
            validate:
          )
        end

        # Normalize a flag (apply NEM12 specification rules)
        #
        # @param flag_or_hash [Flag, Hash, nil] the flag to normalize
        # @return [Flag] normalized flag instance
        #
        # Normalization rules:
        # - nil flags become 'A' (Actual Data)
        # - 'A', 'N' flags: Remove method_flag if present
        # - 'V' flags: Remove both method_flag and reason_code if present
        # - Other flags: Preserve as-is
        def normalize(flag_or_hash)
          # Handle nil input
          return new(quality_flag: 'A', validate: false) if flag_or_hash.nil?

          # Convert to Flag if needed
          flag = flag_or_hash.is_a?(Flag) ? flag_or_hash : from_hash(flag_or_hash)

          normalized_quality = flag.quality_flag || 'A'
          normalized_method = flag.method_flag
          normalized_reason = flag.reason_code

          # Apply normalization rules based on quality flag
          case normalized_quality
          when 'A', 'N'
            # A and N: Remove method_flag (reason_code is optional)
            normalized_method = nil
          when 'V'
            # V: Remove both method_flag and reason_code
            normalized_method = nil
            normalized_reason = nil
          end

          new(
            quality_flag: normalized_quality,
            method_flag: normalized_method,
            reason_code: normalized_reason,
            validate: false
          )
        end

        # Validate a flag and raise an error if invalid
        #
        # @param flag_or_hash [Flag, Hash, nil] the flag to validate
        # @return [void]
        # @raise [ArgumentError] if flag combination is invalid
        #
        # NEM12 Specification Requirements:
        # - 'A' (Actual Data): No method flag, optional reason code
        # - 'N' (Null Data): No method flag, optional reason code *DEPRECATED*
        # - 'V' (Variable Data): No method flag, no reason code
        # - 'E' (Forward Estimated Data): Requires method flag, optional reason code
        # - 'F' (Final Substituted Data): Requires method flag AND reason code
        # - 'S' (Substituted Data): Requires method flag AND reason code
        def validate!(flag_or_hash)
          return if flag_or_hash.nil?

          flag = from_hash(flag_or_hash)

          quality_flag = flag.quality_flag
          method_flag = flag.method_flag
          reason_code = flag.reason_code

          # Validate individual components
          unless valid_quality_flag?(quality_flag)
            raise ArgumentError,
                  "Invalid quality flag: #{quality_flag.inspect}"
          end

          unless valid_method_flag?(method_flag)
            raise ArgumentError,
                  "Invalid method flag: #{method_flag.inspect}"
          end

          unless valid_reason_code?(reason_code)
            raise ArgumentError,
                  "Invalid reason code: #{reason_code.inspect}"
          end

          # Validate flag combinations according to NEM12 specification
          case quality_flag
          when 'A', 'N'
            # A and N: Should not have method flags, may have reason codes
            unless method_flag.nil?
              raise ArgumentError,
                    "Quality flag '#{quality_flag}' should not have a method flag"
            end
          when 'V'
            # V: Should not have method flags or reason codes
            unless method_flag.nil?
              raise ArgumentError,
                    "Quality flag 'V' should not have a method flag"
            end
            unless reason_code.nil?
              raise ArgumentError,
                    "Quality flag 'V' should not have a reason code"
            end
          when 'E'
            # E: Requires method flag, may have reason code (optional)
            if method_flag.nil?
              raise ArgumentError,
                    "Quality flag 'E' requires a method flag"
            end
          when 'F', 'S'
            # F and S: Require both method flag and reason code
            if method_flag.nil?
              raise ArgumentError,
                    "Quality flag '#{quality_flag}' requires a method flag"
            end
            if reason_code.nil?
              raise ArgumentError,
                    "Quality flag '#{quality_flag}' requires a reason code"
            end
          end
        end

        # Validate a quality flag value
        #
        # @param quality_flag [String, nil] the quality flag to validate
        # @return [Boolean] true if valid
        def valid_quality_flag?(quality_flag)
          quality_flag.nil? || QUALITY_FLAGS.key?(quality_flag)
        end

        # Validate a method flag value
        #
        # @param method_flag [Integer, nil] the method flag to validate
        # @return [Boolean] true if valid
        def valid_method_flag?(method_flag)
          method_flag.nil? || METHOD_FLAGS.key?(method_flag)
        end

        # Validate a reason code value
        #
        # @param reason_code [Integer, nil] the reason code to validate
        # @return [Boolean] true if valid
        def valid_reason_code?(reason_code)
          reason_code.nil? || REASON_CODES.key?(reason_code)
        end
      end

      # Convert flag to quality method string
      #
      # @return [String] the quality method string (e.g., 'A', 'E52', 'F11')
      def to_quality_method
        return 'A' if quality_flag.nil?

        qf = quality_flag || 'A'
        mf = method_flag

        # Build quality method string (quality flag + optional method flag)
        if mf.nil?
          qf
        else
          "#{qf}#{format('%02d', mf)}"
        end
      end

      # Convert flag to human-readable string
      #
      # @return [String, nil] a hyphenated string for the flag or nil
      def to_s
        parts = []
        parts << QUALITY_FLAGS[quality_flag] unless QUALITY_FLAGS[quality_flag].nil?
        parts << METHOD_FLAGS[method_flag][:short_descriptor] unless METHOD_FLAGS[method_flag].nil?
        parts << REASON_CODES[reason_code] unless REASON_CODES[reason_code].nil?
        parts.empty? ? nil : parts.join(' - ')
      end

      # Convert flag to hash (backward compatibility)
      #
      # @return [Hash] hash representation of the flag
      def to_h
        {
          quality_flag: @quality_flag,
          method_flag: @method_flag,
          reason_code: @reason_code
        }
      end

      # Equality comparison
      #
      # @param other [Flag, Hash] the other flag to compare
      # @return [Boolean] true if flags are equal
      def ==(other)
        if other.is_a?(Flag)
          quality_flag == other.quality_flag &&
            method_flag == other.method_flag &&
            reason_code == other.reason_code
        elsif other.is_a?(Hash)
          quality_flag == other[:quality_flag] &&
            method_flag == other[:method_flag] &&
            reason_code == other[:reason_code]
        else
          false
        end
      end

      # Hash code for use in hashes and sets
      #
      # @return [Integer] hash code
      def hash
        [quality_flag, method_flag, reason_code].hash
      end

      # Validate the flag and raise an error if invalid
      #
      # @return [void]
      # @raise [ArgumentError] if flag combination is invalid
      def validate!
        self.class.validate!(self)
      end

      # Equality for hash keys
      alias eql? ==
    end
  end
end
