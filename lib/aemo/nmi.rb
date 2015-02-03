require 'csv'
require 'time'
module AEMO
  class NMI
    
    NETWORK_SERVICE_PROVIDERS = {
      'ACTEWP': {
        title: 'Actew Distribution Ltd and Jemena Networks (ACT) Pty Ltd',
        friendly_title: 'ACTEWAgl',
        state: 'ACT',
        includes: [
          ['NGGG000000','NGGGZZZZZZ'],
          ['7001000000','7001999999']
        ],
        excludes: [
          ['NGGGW00000','NGGGW00000']          
        ]
      },
      'CNRGYP': {
        title: 'Essential Energy',
        friendly_title: 'Essential Energy',
        state: 'NSW',
        includes:
        excludes: {
          []
        }
      }
    }
    
    @nmi              = nil
    
    attr_accessor :nmi
    # attr_reader   :data_details, :interval_data, :interval_events
    
    # Initialize a NEM12 file
    #
    # @param [String] nmi the National Meter Identifier (NMI)
    # @param [options] a hash of options
    # @return [AEMO::NMI] an instance of AEMO::NMI is returned
    def initialize(nmi,options={})
      @nmi              = nmi
    end

    # Checksum is a function to calculate the checksum value for a given National Meter Identifier
    #
    # @return [Integer] the checksum value for the current National Meter Identifier
    def checksum
      summation = 0
      @nmi.reverse.split(//).each_index do |i|
        value = nmi[nmi.length - i - 1].ord
        if(i % 2 == 0)
          value = value * 2
        end
        value = value.to_s.split(//).map{|i| i.to_i}.reduce(:+)
        summation += value
      end      
      checksum = (10 - (summation % 10)) % 10
      checksum
    end
  end
  
  # A function to calculate the checksum value for a given National Meter Identifier
  #
  # @param  [Integer] the checksum value to check against the current National Meter Identifier's checksum value
  # @return [Boolean] whether or not the checksum if valid
  def checksum_valid?(checksum_value)
    checksum_value == self.checksum
  end
end
