# encoding: UTF-8
require 'active_support/all'

module AEMO
  class NMI
    # [AEMO::NMI::Address]
    #
    # @author Joel Courtney
    # @abstract
    # @since 0.2.0
    # @attr [String] building_or_property_name
    # @attr [String] location_descriptor
    # @attr [String] lot_number
    # @attr [String] flat_or_unit_number
    # @attr [String] flat_or_unit_type
    # @attr [String] floor_or_level_number
    # @attr [String] floor_or_level_type
    # @attr [Integer] house_number
    # @attr [String] house_number_suffix
    # @attr [String] street_name
    # @attr [String] street_suffix
    # @attr [String] street_type
    # @attr [String] suburb_or_place_or_locality
    # @attr [String] post_code
    # @attr [String] state_or_territory
    class Address
      attr_accessor :building_or_property_name,
                    :lot_number,
                    :flat_or_unit_number,
                    :flat_or_unit_type,
                    :floor_or_level_number,
                    :floor_or_level_type,
                    :house_number,
                    :house_number_suffix,
                    :street_name,
                    :street_suffix,
                    :street_type,
                    :suburb_or_place_or_locality,
                    :location_descriptor,
                    :post_code,
                    :state_or_territory

      class << self
        # Parses an AEMO Hash to an Address
        #
        # @param [Hash] address
        # @option address [String] 'BuildingOrPropertyName'
        # @option address [String] 'LocationDescriptor'
        # @option address [String] 'LotNumber'
        # @option address [String] 'FlatOrUnitNumber'
        # @option address [String] 'FlatOrUnitType'
        # @option address [String] 'FloorOrLevelNumber'
        # @option address [String] 'FloorOrLevelType'
        # @option address [Integer] 'HouseNumber'
        # @option address [String] 'HouseNumberSuffix'
        # @option address [String] 'StreetName'
        # @option address [String] 'StreetSuffix'
        # @option address [String] 'StreetType'
        # @option address [String] 'SuburbOrPlaceOrLocality'
        # @option address [String] 'PostCode'
        # @option address [String] 'StateOrTerritory'
        # @return [AEMO::NMI::Address]
        def parse_msats_hash(address)
          address = address.to_a.map { |x| [x[0].underscore.to_sym, x[1]] }.to_h
          unless address[:structured_address].nil?
            address[:structured_address].each_pair do |key, value|
              if value.is_a?(Hash)
                value.each_pair do |key_2, value_2|
                  address[key_2.underscore.to_sym] = value_2
                end
              else
                address[key.underscore.to_sym] = value
              end
            end
          end

          AEMO::NMI::Address.new(address)
        end
      end

      # Creates a new AEMO::NMI::Address
      #
      # @param [Hash] address
      # @option address [String] :building_or_property_name
      # @option address [String] :lot_number
      # @option address [String] :flat_or_unit_number
      # @option address [String] :flat_or_unit_type
      # @option address [String] :floor_or_level_number
      # @option address [String] :floor_or_level_type
      # @option address [Integer] :house_number
      # @option address [String] :house_number_suffix
      # @option address [String] :street_name
      # @option address [String] :street_suffix
      # @option address [String] :street_type
      # @option address [String] :suburb_or_place_or_locality
      # @option address [String] :location_descriptor
      # @option address [String] :post_code
      # @option address [String] :state_or_territory
      # @return [AEMO::NMI::Address]
      def initialize(address)
        @building_or_property_name = address[:building_or_property_name]
        @location_descriptor = address[:location_descriptor]
        @lot_number = address[:lot_number]
        @flat_or_unit_number = address[:flat_or_unit_number]
        @flat_or_unit_type = address[:flat_or_unit_type]
        @floor_or_level_number = address[:floor_or_level_number]
        @floor_or_level_type = address[:floor_or_level_type]
        @house_number = address[:house_number]
        @house_number_suffix = address[:house_number_suffix]
        @street_name = address[:street_name]
        @street_suffix = address[:street_suffix]
        @street_type = address[:street_type]
        @suburb_or_place_or_locality = address[:suburb_or_place_or_locality]
        @post_code = address[:post_code]
        @state_or_territory = address[:state_or_territory]

        self
      end

      # Returns the String form of the address
      #
      # @return [String]
      def to_s
        [
          @building_or_property_name,
          @location_descriptor,
          [@lot_number, @flat_or_unit_number, @flat_or_unit_type, @floor_or_level_number, @floor_or_level_type].compact.join(' '),
          ["#{@house_number}#{@house_number_suffix}", @street_name, @street_suffix, @street_type].reject(&:blank?).compact.join(' '),
          [@suburb_or_place_or_locality, @state_or_territory, @post_code].compact.join(' ')
        ].reject(&:blank?).join(', ')
      end
    end
  end
end
