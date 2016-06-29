# encoding: UTF-8

module AEMO
  class NMI
    # [AEMO::NMI::Meter]
    #
    # @author Joel Courtney
    # @abstract
    # @since 0.2.0
    # @attr [String] serial_number
    # @attr [Integer] nem12_meter
    # @attr [Date] next_scheduled_read_date
    # @attr [String] installation_type_code
    # @attr [String] read_type_code
    # @attr [String] status
    # @attr [String] registers
    class Meter
      # Meter Information
      @serial_number            = nil
      @next_scheduled_read_date = nil
      @installation_type_code   = nil
      @read_type_code           = nil
      @status                   = nil

      # NEM12 Information - Meter Serial not necessarily provided
      @nem12_meter              = nil

      # Registers
      @registers                = []

      # Attribute Accessors
      attr_accessor :serial_number, :nem12_meter, :next_scheduled_read_date, :installation_type_code, :read_type_code, :status, :registers

      # Creates a new instance of the AEMO::NMI::Meter
      #
      # @param [Hash] options
      # @option options [String] :serial_number
      # @option options [Integer] :nem12_meter
      # @option options [Date] :next_scheduled_read_date
      # @option options [String] :installation_type_code
      # @option options [String] :read_type_code
      # @option options [String] :status
      # @option options [String] :registers
      # @return [AEMO::NMI::Meter]
      def initialize(options = {})
        # Serial Number
        unless options[:serial_number].nil?
          raise ArgumentError, 'Meter Serial Number is not a string' unless options[:serial_number] =~ /^[A-Z0-9]{0,12}$/i
          raise ArgumentError, "Meter Serial Number #{options[:serial_number]} is not valid" unless options[:serial_number] =~ /^[A-Z0-9]{0,12}$/i
          @serial_number = options[:serial_number]
        end

        unless options[:nem12_meter].nil?
          raise ArgumentError, 'NEM12 Meter is invalid' unless options[:nem12_meter].is_a?(Integer)
          @nem12_meter = options[:nem12_meter]
        end

        unless options[:next_scheduled_read_date].nil?
          raise ArgumentError, "Next Scheduled Read Date #{options[:next_scheduled_read_date]} is not valid" unless options[:next_scheduled_read_date].is_a?(Date)
          @next_scheduled_read_date = options[:next_scheduled_read_date]
        end

        unless options[:installation_type_code].nil?
          raise ArgumentError, 'Installation Type Code is not a string' unless options[:installation_type_code].is_a?(String)
          @installation_type_code = options[:installation_type_code]
        end

        unless options[:read_type_code].nil?
          raise ArgumentError, 'Read Type Code is not a string' unless options[:read_type_code].is_a?(String)
          @read_type_code = options[:read_type_code]
        end

        unless options[:status].nil?
          raise ArgumentError, 'Meter Status is not a string' unless options[:status].is_a?(String)
          raise ArgumentError, "Meter Status #{options[:status]} is not a valid status" unless options[:status] =~ /^[CR]$/i
          @status = options[:status]
        end

        unless options[:registers].nil?
          raise ArgumentError, 'Registers are not a string' unless options[:registers].is_a?(String)
          raise ArgumentError, "Registers #{options[:registers]} is not valid" unless options[:registers] =~ /^([A-Z]\d+)+$/
          options[:registers].scan(/([A-Z]\d+)/).flatten.each do |register|
            @registers ||= []
            @registers << AEMO::NMI::Register.new(register, register, nil)
          end
        end
      end
    end
  end
end
