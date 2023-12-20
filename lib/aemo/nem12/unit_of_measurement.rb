# frozen_string_literal: true

module AEMO
  # Namespace for classes and modules that handle AEMO Gem NEM12 interactions
  # @since 0.1.4
  class NEM12
    UOM = {
      'MWh' => { name: 'Megawatt Hour', multiplier: 1e6 },
      'kWh' => { name: 'Kilowatt Hour', multiplier: 1e3 },
      'Wh' => { name: 'Watt Hour', multiplier: 1 },
      'MW' => { name: 'Megawatt', multiplier: 1e6 },
      'kW' => { name: 'Kilowatt', multiplier: 1e3 },
      'W' => { name: 'Watt', multiplier: 1 },
      'MVArh' => { name: 'Megavolt Ampere Reactive Hour', multiplier: 1e6 },
      'kVArh' => { name: 'Kilovolt Ampere Reactive Hour', multiplier: 1e3 },
      'VArh' => { name: 'Volt Ampere Reactive Hour', multiplier: 1 },
      'MVAr' => { name: 'Megavolt Ampere Reactive', multiplier: 1e6 },
      'kVAr' => { name: 'Kilovolt Ampere Reactive', multiplier: 1e3 },
      'VAr' => { name: 'Volt Ampere Reactive', multiplier: 1 },
      'MVAh' => { name: 'Megavolt Ampere Hour', multiplier: 1e6 },
      'kVAh' => { name: 'Kilovolt Ampere Hour', multiplier: 1e3 },
      'VAh' => { name: 'Volt Ampere Hour', multiplier: 1 },
      'MVA' => { name: 'Megavolt Ampere', multiplier: 1e6 },
      'kVA' => { name: 'Kilovolt Ampere', multiplier: 1e3 },
      'VA' => { name: 'Volt Ampere', multiplier: 1 },
      'kV' => { name: 'Kilovolt', multiplier: 1e3 },
      'V' => { name: 'Volt', multiplier: 1 },
      'kA' => { name: 'Kiloampere', multiplier: 1e3 },
      'A' => { name: 'Ampere', multiplier: 1 },
      'pf' => { name: 'Power Factor', multiplier: 1 }
    }.freeze

    UOM_NON_SPEC_MAPPING = {
      'MWH' => 'MWh',
      'KWH' => 'kWh',
      'WH' => 'Wh',
      'MW' => 'MW',
      'KW' => 'kW',
      'W' => 'W',
      'MVARH' => 'MVArh',
      'KVARH' => 'kVArh',
      'VARH' => 'VArh',
      'MVAR' => 'MVAr',
      'KVAR' => 'kVAr',
      'VAR' => 'VAr',
      'MVAH' => 'MVAh',
      'KVAH' => 'kVAh',
      'VAH' => 'VAh',
      'MVA' => 'MVA',
      'KVA' => 'kVA',
      'VA' => 'VA',
      'KV' => 'kV',
      'V' => 'V',
      'KA' => 'kA',
      'A' => 'A',
      'PF' => 'pf'
    }.freeze
  end
end
