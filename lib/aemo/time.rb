# frozen_string_literal: true

require 'time'
require 'active_support/all'

require_relative 'exceptions/time_error'

module AEMO
  # [AEMO::Time] provides time helpers for AEMO services.
  module Time
    NEMTIMEZONE = 'Australia/Brisbane'
    TIMESTAMP14 = '%Y%m%d%H%M%S'
    TIMESTAMP14_PATTERN = /^\d{4}\d{2}\d{2}\d{2}\d{2}\d{2}$/
    TIMESTAMP12 = '%Y%m%d%H%M'
    TIMESTAMP12_PATTERN = /^\d{4}\d{2}\d{2}\d{2}\d{2}$/
    TIMESTAMP8 = '%Y%m%d'
    TIMESTAMP8_PATTERN = /^\d{4}\d{2}\d{2}$/

    class << self
      # Format a time to a timestamp 14.
      #
      # @param [Time] time
      # @return [String]
      def format_timestamp14(time)
        time.in_time_zone(NEMTIMEZONE).strftime(TIMESTAMP14)
      end

      # Format a time to a timestamp 12.
      #
      # @param [Time] time
      # @return [String]
      def format_timestamp12(time)
        time.in_time_zone(NEMTIMEZONE).strftime(TIMESTAMP12)
      end

      # Format a time to a timestamp 8.
      #
      # @param [Time] time
      # @return [String]
      def format_timestamp8(time)
        time.in_time_zone(NEMTIMEZONE).strftime(TIMESTAMP8)
      end

      # Parse a 14 character timestamp.
      #
      # @param [String] string
      # @raise [AEMO::TimeError]
      # @return [Time]
      def parse_timestamp14(string)
        raise AEMO::TimeError unless string.match(TIMESTAMP14_PATTERN)

        ::Time.find_zone(NEMTIMEZONE).strptime(string, TIMESTAMP14)
      end

      # Parse a 12 character timestamp.
      #
      # @param [String] string
      # @return [Time]
      def parse_timestamp12(string)
        raise AEMO::TimeError unless string.match(TIMESTAMP12_PATTERN)

        ::Time.find_zone(NEMTIMEZONE).strptime(string, TIMESTAMP12)
      end

      # Parse an 8 character date.
      #
      # @param [String] string
      # @return [Time]
      def parse_timestamp8(string)
        raise AEMO::TimeError unless string.match(TIMESTAMP8_PATTERN)

        ::Time.find_zone(NEMTIMEZONE).strptime(string, TIMESTAMP8)
      end

      # Check if a string is a valid timestamp 14.
      #
      # @param [String] string
      # @return [Boolean]
      def valid_timestamp14?(string)
        parse_timestamp14(string)

        true
      rescue AEMO::TimeError
        false
      end

      # Check if a string is a valid timestamp 12.
      #
      # @param [String] string
      # @return [Boolean]
      def valid_timestamp12?(string)
        parse_timestamp12(string)

        true
      rescue AEMO::TimeError
        false
      end

      # Check if a string is a valid timestamp 8.
      #
      # @param [String] string
      # @return [Boolean]
      def valid_timestamp8?(string)
        parse_timestamp8(string)

        true
      rescue AEMO::TimeError
        false
      end
    end
  end
end
