# frozen_string_literal: true

module AEMO
  # AEMO::Meter represents a meter under a NMI
  class Meter
    attr_accessor :installation_type_code, :next_scheduled_read_date,
                  :read_type_code, :registers, :serial_number, :status

    # Initialize a meter
    #
    # @param [Hash] opts = {} the parameters to set
    # @return [AEMO::Meter] an instance of an AEMO::Meter
    def initialize(opts = {})
      @installation_type_code   = opts[:installation_type_code]
      @next_scheduled_read_date = opts[:next_scheduled_read_date]
      @read_type_code           = opts[:read_type_code]
      @registers                = opts[:registers] || []
      @serial_number            = opts[:serial_number]
      @status                   = opts[:status]
    end

    # Initialize a new meter from an MSATS hash
    #
    # @param [Hash] meter the MSATS hash
    # @return [AEMO::Meter] description of returned object
    def self.from_hash(meter)
      AEMO::Meter.new(
        installation_type_code: meter['InstallationTypeCode'],
        next_scheduled_read_date: meter['NextScheduledReadDate'],
        read_type_code: meter['ReadTypeCode'],
        registers: [],
        serial_number: meter['SerialNumber'],
        status: meter['Status']
      )
    end
  end
end
