module AEMO
  class NEM12
    RECORD_INDICATORS = {
      100 => 'Header',
      200 => 'NMI Data Details',
      300 => 'Interval Data',
      400 => 'Interval Event',
      500 => 'B2B Details',
      900 => 'End'
    }
    
    attr_accessor :nmi
    
    # Initialize a NEM12 file
    def initialize(nmi,options={})
      @nmi = nmi
    end
    
    # @return [Integer] checksum of the NMI
    def nmi_checksum
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

    def parse_nem12_file(contents)
      
    end
    
    def parse_nem12(contents)
      
    end
    
    def parse_nem12_100(row)
      
    end
    
    # @param nmi [String] a NMI that is to be checked for validity
    # @return [Boolean] determines if the NMI is valid
    def self.valid_nmi?(nmi)
      (nmi.class == String && nmi.length == 10 && !nmi.match(/^[A-Z1-9][A-Z0-9]{9}$/).nil?)
    end
    
  end
end