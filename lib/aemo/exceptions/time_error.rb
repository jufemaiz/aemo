# frozen_string_literal: true

module AEMO
  # AEMO::TimeError
  #
  # @author Joel Courtney
  # @abstract An exception for time errors.
  # @since 0.6.0
  class TimeError < ArgumentError
    DEFAULT_MESSAGE = 'Not a valid time'

    # Initialize an TimeError
    #
    # @param [String] msg the error message
    # @return [AEMO::TimeError]
    def initialize(msg: DEFAULT_MESSAGE)
      super
    end
  end
end
