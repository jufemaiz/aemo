# frozen_string_literal: true

module AEMO
  # Namespace for classes and modules that handle AEMO Gem NEM12 interactions
  # @since 0.1.4
  class NEM12
    # As per AEMO NEM12 Specification
    # http://www.aemo.com.au/Consultations/National-Electricity-Market/Open/~/media/
    # Files/Other/consultations/nem/Meter% 20Data% 20File% 20Format% 20Specification% 20
    # NEM12_NEM13/MDFF_Specification_NEM12_NEM13_Final_v102_clean.ashx
    RECORD_INDICATORS = {
      100 => 'Header',
      200 => 'NMI Data Details',
      300 => 'Interval Data',
      400 => 'Interval Event',
      500 => 'B2B Details',
      900 => 'End'
    }.freeze
  end
end
