# [AEMO::NMI::NMI_TNI_CODES, AEMO::NMI::DLF_CODES]
module AEMO
  class NMI
    # Transmission Node Identifier Codes are loaded from a json file
    #  Obtained from http://www.nemweb.com.au/
    #
    #  See /lib/data for further data manipulation required
    TNI_CODES = JSON.parse(File.read(File.join(File.dirname(__FILE__), '..', '..', 'data', 'aemo-tni.json'))).freeze

    # Distribution Loss Factor Codes are loaded from a json file
    #  Obtained from MSATS, matching to DNSP from file http://www.aemo.com.au/Electricity/Market-Operations/Loss-Factors-and-Regional-Boundaries/~/media/Files/Other/loss% 20factors/DLF_FINAL_V2_2014_2015.ashx
    #  Last accessed 2015-02-06
    #  See /lib/data for further data manipulation required
    DLF_CODES = JSON.parse(File.read(File.join(File.dirname(__FILE__), '..', '..', 'data', 'aemo-dlf.json'))).freeze
  end
end
