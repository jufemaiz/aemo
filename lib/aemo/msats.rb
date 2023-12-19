# frozen_string_literal: true

require 'digest/sha1'
require 'httparty'
require 'nokogiri'

module AEMO
  # AEMO::MSATS
  #
  # @author Joel Courtney
  # @abstract
  # @since 0.1.0
  class MSATS
    # Globally set request headers
    HEADERS = {
      'User-Agent' => 'Ruby.AEMO.MSATS.Api',
      'Accept' => 'text/xml',
      'Content-Type' => 'text/xml'
    }.freeze

    # We like to party
    include HTTParty
    # We like to debug
    # debug_output $stdout

    # We like to :TLSv1
    ssl_version :TLSv1

    # Where we like to party
    base_uri 'https://msats.prod.nemnet.net.au/msats/ws/'

    # Class Methods
    class << self
      attr_accessor :auth, :participant_id

      # Single NMI Master (C4) Report
      # /C4/PARTICIPANT_IDENTIFIER?transactionId=XXX&nmi=XXX&checksum=X&type=XXX&reason=XXX
      #
      # @param [String, AEMO::NMI] nmi   the NMI to run the master report against
      # @param [Date, String] from_date  the from date for the master report
      # @param [Date, String] to_date  the from date for the master report
      # @return [Hash] A hashed view of the NMI Standing Data for a given NMI
      def c4(nmi, from_date, to_date, as_at_date, options = {})
        nmi         = AEMO::NMI.new(nmi) if nmi.is_a?(String)
        from_date   = Date.parse(from_date) if from_date.is_a?(String)
        to_date     = Date.parse(to_date) if to_date.is_a?(String)
        as_at_date  = Date.parse(as_at_date) if as_at_date.is_a?(String)

        options[:participantId]   ||= nil
        options[:roleId]          ||= nil
        options[:inittransId]     ||= nil

        query = {
          transactionId: transaction_id,
          # NOTE: AEMO has case sensitivity but no consistency across requests.
          NMI: nmi.nmi,
          fromDate: from_date,
          toDate: to_date,
          asatDate: as_at_date,
          participantId: @participant_id,
          roleId: options[:role_id],
          inittransId: options[:init_trans_id]
        }

        response = get("/C4/#{@participant_id}", basic_auth: @auth, headers: HEADERS, query:,
                                                 verify: (options[:verify_ssl] != false))
        if response.response.code == '200'
          response.parsed_response['aseXML']['Transactions']['Transaction']['ReportResponse']['ReportResults']
        else
          response
        end
      end

      # MSATS Limits
      # /MSATSLimits/PARTICIPANT_IDENTIFIER?transactionId=XXX
      #
      # @return [Hash] The report results from the MSATS Limits web service query
      def msats_limits(options = {})
        query = {
          transactionId: transaction_id
        }
        response = get("/MSATSLimits/#{@participant_id}", basic_auth: @auth, headers: HEADERS, query:,
                                                          verify: (options[:verify_ssl] != false))
        if response.response.code == '200'
          response.parsed_response['aseXML']['Transactions']['Transaction']['ReportResponse']['ReportResults']
        else
          response
        end
      end

      # NMI Discovery - By Delivery Point Identifier
      #
      # @param [String] jurisdiction_code The Jurisdiction Code
      # @param [Integer] delivery_point_identifier Delivery Point Identifier
      # @return [Hash] The response
      def nmi_discovery_by_delivery_point_identifier(jurisdiction_code, delivery_point_identifier, options = {})
        raise ArgumentError, 'jurisdiction_code is not valid' unless %w[ACT NEM NSW QLD SA VIC
                                                                        TAS].include?(jurisdiction_code)

        unless delivery_point_identifier.respond_to?('to_i')
          raise ArgumentError,
                'delivery_point_identifier is not valid'
        end
        if delivery_point_identifier.to_i < 10_000_000 || delivery_point_identifier.to_i > 99_999_999
          raise ArgumentError,
                'delivery_point_identifier is not valid'
        end

        query = {
          transactionId: transaction_id,
          jurisdictionCode: jurisdiction_code,
          deliveryPointIdentifier: delivery_point_identifier.to_i
        }

        response = get("/NMIDiscovery/#{@participant_id}", basic_auth: @auth, headers: HEADERS, query:,
                                                           verify: (options[:verify_ssl] != false))
        if response.response.code == '200'
          response.parsed_response['aseXML']['Transactions']['Transaction']['NMIDiscoveryResponse']['NMIStandingData']
        else
          response
        end
      end

      # NMI Discovery - By Meter Serial Numner
      #
      # @param [String] jurisdiction_code The Jurisdiction Code
      # @param [Integer] meter_serial_number The meter's serial number
      # @return [Hash] The response
      def nmi_discovery_by_meter_serial_number(jurisdiction_code, meter_serial_number, options = {})
        raise ArgumentError, 'jurisdiction_code is not valid' unless %w[ACT NEM NSW QLD SA VIC
                                                                        TAS].include?(jurisdiction_code)

        query = {
          transactionId: transaction_id,
          jurisdictionCode: jurisdiction_code,
          meterSerialNumber: meter_serial_number.to_i
        }

        response = get("/NMIDiscovery/#{@participant_id}", basic_auth: @auth, headers: HEADERS, query:,
                                                           verify: (options[:verify_ssl] != false))
        if response.response.code == '200'
          response.parsed_response['aseXML']['Transactions']['Transaction']['NMIDiscoveryResponse']['NMIStandingData']
        else
          response
        end
      end

      # NMI Discovery - By Address
      #
      # @param [String] jurisdiction_code The Jurisdiction Code
      # @param [Integer] meter_serial_number The meter's serial number
      # @return [Hash] The response
      def nmi_discovery_by_address(jurisdiction_code, options = {})
        raise ArgumentError, 'jurisdiction_code is not valid' unless %w[ACT NEM NSW QLD SA VIC
                                                                        TAS].include?(jurisdiction_code)

        options[:building_or_property_name] ||= nil
        options[:location_descriptor] ||= nil
        options[:lot_number] ||= nil
        options[:flat_or_unit_number] ||= nil
        options[:flat_or_unit_type] ||= nil
        options[:floor_or_level_number] ||= nil
        options[:floor_or_level_type] ||= nil
        options[:house_number] ||= nil
        options[:house_number_suffix] ||= nil
        options[:street_name] ||= nil
        options[:street_suffix] ||= nil
        options[:street_type] ||= nil
        options[:suburb_or_place_or_locality] ||= nil
        options[:postcode] ||= nil
        options[:state_or_territory] ||= jurisdiction_code

        query = {
          transactionId: transaction_id,
          jurisdictionCode: jurisdiction_code,
          buildingOrPropertyName: options[:building_or_property_name],
          locationDescriptor: options[:location_descriptor],
          lotNumber: options[:lot_number],
          flatOrUnitNumber: options[:flat_or_unit_number],
          flatOrUnitType: options[:flat_or_unit_type],
          floorOrLevelNumber: options[:floor_or_level_number],
          floorOrLevelType: options[:floor_or_level_type],
          houseNumber: options[:house_number],
          houseNumberSuffix: options[:house_number_suffix],
          streetName: options[:street_name],
          streetSuffix: options[:street_suffix],
          streetType: options[:street_type],
          suburbOrPlaceOrLocality: options[:suburb_or_place_or_locality],
          postcode: options[:postcode],
          stateOrTerritory: options[:state_or_territory]
        }

        response = get("/NMIDiscovery/#{@participant_id}", basic_auth: @auth, headers: HEADERS, query:,
                                                           verify: (options[:verify_ssl] != false))
        if response.response.code == '200'
          myresponse = response.parsed_response['aseXML']['Transactions']['Transaction']['NMIDiscoveryResponse']['NMIStandingData']
          myresponse.is_a?(Hash) ? [myresponse] : myresponse
        else
          response
        end
      end

      # NMI Detail
      # /NMIDetail/PARTICIPANT_IDENTIFIER?transactionId=XXX&nmi=XXX&checksum=X&type=XXX&reason=XXX
      #
      # @return [Hash] A hashed view of the NMI Standing Data for a given NMI
      def nmi_detail(nmi, options = {})
        nmi = AEMO::NMI.new(nmi) if nmi.is_a?(String)

        options[:type]    ||= nil
        options[:reason]  ||= nil

        query = {
          transactionId: transaction_id,
          nmi: nmi.nmi,
          checksum: nmi.checksum,
          type: options[:type],
          reason: options[:reason]
        }

        response = get("/NMIDetail/#{@participant_id}", basic_auth: @auth, headers: HEADERS, query:,
                                                        verify: (options[:verify_ssl] != false))
        if response.response.code == '200'
          response.parsed_response['aseXML']['Transactions']['Transaction']['NMIStandingDataResponse']['NMIStandingData']
        else
          response
        end
      end

      # Participant System Status
      # /ParticipantSystemStatus/PARTICIPANT_IDENTIFIER?transactionId=XXX
      #
      # @return [Hash] The report results from the Participant System Status web service query
      def system_status(options = {})
        query = {
          transactionId: transaction_id
        }
        response = get("/ParticipantSystemStatus/#{@participant_id}", basic_auth: @auth, headers: HEADERS,
                                                                      query:, verify: (options[:verify_ssl] != false))
        if response.response.code == '200'
          response.parsed_response['aseXML']['Transactions']['Transaction']['ReportResponse']['ReportResults']
        else
          response
        end
      end

      # Sets the authentication credentials in a class variable.
      #
      # @param [String] email cl.ly email
      # @param [String] password cl.ly password
      # @return [Hash] authentication credentials
      def authorize(participant_id, username, password)
        @participant_id  = participant_id
        @auth            = { username:, password: }
      end

      # Check if credentials are available to use
      #
      # @return [Boolean] true/false if credentials are available
      def can_authenticate?
        !(@participant_id.nil? || @auth[:username].nil? || @auth[:password].nil?)
      end

      # Method for creating a unique transaction id
      #
      # @return [String] the transaction id
      def transaction_id
        Digest::SHA1.hexdigest(Time.now.to_s)[0..35]
      end
    end

    # Instance Methods
    def initialize(options = {})
      @auth = { username: nil, password: nil }

      @auth[:username]  = options[:username]        if options[:username].is_a?(String)
      @auth[:password]  = options[:password]        if options[:password].is_a?(String)
      @participant_id   = options[:participant_id]  if options[:participant_id].is_a?(String)
    end
  end
end
