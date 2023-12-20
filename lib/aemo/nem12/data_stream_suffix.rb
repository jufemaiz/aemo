# frozen_string_literal: true

module AEMO
  # Namespace for classes and modules that handle AEMO Gem NEM12 interactions
  # @since 0.1.4
  class NEM12
    DATA_STREAM_SUFFIX = {
      # Averaged Data Streams
      'A' => { stream: 'Average', description: 'Import', units: 'kWh' },
      'D' => { stream: 'Average', description: 'Export', units: 'kWh' },
      'J' => { stream: 'Average', description: 'Import', units: 'kVArh' },
      'P' => { stream: 'Average', description: 'Export', units: 'kVArh' },
      'S' => { stream: 'Average', description: '',       units: 'kVAh' },
      # Master Data Streams
      'B' => { stream: 'Master',  description: 'Import', units: 'kWh' },
      'E' => { stream: 'Master',  description: 'Export', units: 'kWh' },
      'K' => { stream: 'Master',  description: 'Import', units: 'kVArh' },
      'Q' => { stream: 'Master',  description: 'Export', units: 'kVArh' },
      'T' => { stream: 'Master',  description: '',       units: 'kVAh' },
      'G' => { stream: 'Master',  description: 'Power Factor', units: 'PF' },
      'H' => { stream: 'Master',  description: 'Q Metering', units: 'Qh' },
      'M' => { stream: 'Master',  description: 'Par Metering', units: 'parh' },
      'V' => { stream: 'Master',  description: 'Volts or V2h or Amps or A2h', units: '' },
      # Check Meter Streams
      'C' => { stream: 'Check',  description: 'Import', units: 'kWh' },
      'F' => { stream: 'Check',  description: 'Export', units: 'kWh' },
      'L' => { stream: 'Check',  description: 'Import', units: 'kVArh' },
      'R' => { stream: 'Check',  description: 'Export', units: 'kVArh' },
      'U' => { stream: 'Check',  description: '',       units: 'kVAh' },
      'Y' => { stream: 'Check',  description: 'Q Metering',         units: 'Qh' },
      'W' => { stream: 'Check',  description: 'Par Metering Path',  units: '' },
      'Z' => { stream: 'Check',  description: 'Volts or V2h or Amps or A2h',  units: '' }
      # Net Meter Streams
      # AEMO: NOTE THAT D AND J ARE PREVIOUSLY DEFINED
      # 'D' => { stream: 'Net',    description: 'Net', units: 'kWh' },
      # 'J' => { stream: 'Net',    description: 'Net', units: 'kVArh' }
    }.freeze
  end
end
