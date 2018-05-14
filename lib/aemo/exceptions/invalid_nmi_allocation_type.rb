# frozen_string_literal: true

module AEMO
  class InvalidNMIAllocationType < ArgumentError
    DEFAULT_MESSAGE = "Not a valid allocation type, try one of " \
                      "#{AEMO::NMI::Allocation::SUPPORTED_TYPES.join(' |')}"

    def initialize(msg=DEFAULT_MESSAGE)
      super
    end
  end
end
