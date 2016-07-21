require 'active_support/all'
require 'httparty'
require 'csv'

require 'aemo/region.rb'
require 'aemo/market.rb'
require 'aemo/market/interval.rb'
require 'aemo/market/node.rb'
require 'aemo/nem12.rb'
require 'aemo/nem12/header.rb'
require 'aemo/nem12/nmi_data_details.rb'
require 'aemo/nmi.rb'
require 'aemo/msats.rb'
require 'aemo/version.rb'

# Namespace for classes and modules that handle AEMO interactions
# @since 0.0.0
module AEMO
  class << self
    # Validates a key's value against a pattern
    #
    # @param [Symbol] key
    # @param [String] value
    # @param [Regexp] pattern
    # @return [void]
    def validate_string_pattern(key, value, pattern)
      unless value.is_a?(String)
        raise ArgumentError, "#{key} is not a string"
      end
      unless value =~ pattern
        raise ArgumentError, "#{key} does not meet specification (#{pattern})"
      end
    end
  end
end
