# encoding: UTF-8
require 'active_support/all'

module AEMO
  class NMI
    # [AEMO::NMI::Role]
    #
    # @author Joel Courtney
    # @abstract
    # @since 0.2.0
    # @attr [String] title
    # @attr [String] party
    class Role
      @title = nil
      @party = nil
      attr_accessor :title, :party
      class << self
        # Returns an array of Roles
        #
        # @param [Array<Hash>, Hash] data either a single role or array of roles in MSATS format
        # @return [Array<AEMO::NMI::Role>]
        def parse_msats_hash(data)
          roles = []
          data = [data] if data.is_a?(Hash)
          data.each do |datum|
            roles << AEMO::NMI::Role.new(datum['Role'], datum['Party'])
          end
          roles
        end
      end

      # Creates a new AEMO::NMI::Role
      #
      # @param [String] title title of the role
      # @param [String] party party providing the role
      # @return [AEMO::NMI::Role]
      def initialize(title, party)
        @title = title
        @party = party
      end
    end
  end
end
