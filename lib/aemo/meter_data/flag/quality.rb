# frozen_string_literal: true

module AEMO
  module MeterData
    class Flag
      # Quality flags for NEM12/NEM13 meter data
      # @since 0.1.4
      QUALITY_FLAGS = {
        'A' => 'Actual Data',
        'E' => 'Forward Estimated Data',
        'F' => 'Final Substituted Data',
        'N' => 'Null Data',
        'S' => 'Substituted Data',
        'V' => 'Variable Data'
      }.freeze
    end
  end
end
