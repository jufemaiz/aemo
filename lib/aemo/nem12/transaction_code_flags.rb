# frozen_string_literal: true

module AEMO
  # Namespace for classes and modules that handle AEMO Gem NEM12 interactions
  # @since 0.1.4
  class NEM12
    TRANSACTION_CODE_FLAGS = {
      'A' => 'Alteration',
      'C' => 'Meter Reconfiguration',
      'G' => 'Re-energisation',
      'D' => 'De-energisation',
      'E' => 'Forward Estimate',
      'N' => 'Normal Read',
      'O' => 'Other',
      'S' => 'Special Read',
      'R' => 'Removal of Meter'
    }.freeze
  end
end
