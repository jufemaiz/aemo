# frozen_string_literal: true

module AEMO
  # AEMO::InvalidNMIAllocationType
  #
  # @author Stuart Auld
  # @abstract An exception representing an invalid NMI allocation type
  # @since 0.3.0
  class InvalidNMIAllocationType < ArgumentError
    DEFAULT_MESSAGE = 'Not a valid allocation type, try one of ' \
                      "#{AEMO::NMI::Allocation::SUPPORTED_TYPES.join(' |')}".freeze

    # Initialize an InvalidNMIAllocationType
    #
    # @param [String] msg the error message
    # @return [AEMO::InvalidNMIAllocationType]
    def initialize(msg = DEFAULT_MESSAGE)
      super
    end
  end
end
