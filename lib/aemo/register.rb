# frozen_string_literal: true

module AEMO
  # AEMO::Register represents a register on a meter
  class Register
    attr_accessor :controlled_load, :dial_format, :multiplier,
                  :network_tariff_code, :register_id, :status, :time_of_day,
                  :unit_of_measure

    # Initialize a register
    #
    # @param [Hash] opts = {} the parameters to set
    # @return [AEMO::Register] an instance of an AEMO::Register
    def initialize(opts = {})
      @controlled_load     = opts[:controlled_load]
      @dial_format         = opts[:dial_format]
      @multiplier          = opts[:multiplier]
      @network_tariff_code = opts[:network_tariff_code]
      @register_id         = opts[:register_id]
      @status              = opts[:status]
      @time_of_day         = opts[:time_of_day]
      @unit_of_measure     = opts[:unit_of_measure]
    end

    # Initialize a new register from an MSATS hash
    #
    # @param [Hash] register the MSATS hash
    # @return [AEMO::Register] description of returned object
    def self.from_hash(register)
      AEMO::Register.new(
        controlled_load:     register['ControlledLoad'] == 'Y',
        dial_format:         register['DialFormat'],
        multiplier:          register['Multiplier'],
        network_tariff_code: register['NetworkTariffCode'],
        register_id:         register['RegisterID'],
        status:              register['Status'],
        time_of_day:         register['TimeOfDay'],
        unit_of_measure:     register['UnitOfMeasure']
      )
    end
  end
end
