# [AEMO::NMI::NMI_ALLOCATIONS]
module AEMO
  class NMI
    # NMI_ALLOCATIONS as per AEMO Documentation at http://aemo.com.au/Electricity/Policies-and-Procedures/Retail-and-Metering/~/media/Files/Other/Retail% 20and% 20Metering/NMI_Allocation_List_v7_June_2012.ashx
    #   Last accessed 2015-02-04
    NMI_ALLOCATIONS = {
      'ACTEWP' => {
        title: 'Actew Distribution Ltd and Jemena Networks (ACT) Pty Ltd',
        friendly_title: 'ACTEWAgl',
        state: 'ACT',
        type: 'electricity',
        includes: [
          /^(NGGG[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(7001\d{6})$/
        ],
        excludes: [
        ]
      },
      'CNRGYP' => {
        title: 'Essential Energy',
        friendly_title: 'Essential Energy',
        state: 'NSW',
        type: 'electricity',
        includes: [
          /^(NAAA[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(NBBB[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(NDDD[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(NFFF[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(4001\d{6})$/,
          /^(4508\d{6})$/,
          /^(4204\d{6})$/,
          /^(4407\d{6})$/
        ],
        excludes: [
        ]
      },
      'ENERGYAP' => {
        title: 'Ausgrid',
        friendly_title: 'Ausgrid',
        state: 'NSW',
        type: 'electricity',
        includes: [
          /^(NCCC[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(410[234]\d{6})$/
        ],
        excludes: [
        ]
      },
      'INTEGP' => {
        title: 'Endeavour Energy',
        friendly_title: 'Endeavour Energy',
        state: 'NSW',
        type: 'electricity',
        includes: [
          /^(NEEE[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(431\d{7})$/
        ],
        excludes: [
        ]
      },
      'TRANSGP' => {
        title: 'TransGrid',
        friendly_title: 'TransGrid',
        state: 'NSW',
        type: 'electricity',
        includes: [
          /^(NTTT[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(460810[0-8]\d{3})$/
        ],
        excludes: [
        ]
      },
      'SNOWY' => {
        title: 'Snowy Hydro Ltd',
        friendly_title: 'Snowy Hydro',
        state: 'NSW',
        type: 'electricity',
        includes: [
          /^(4708109\d{3})$/
        ],
        excludes: [
        ]
      },
      'NT_RESERVED' => {
        title: 'Northern Territory Reserved Block',
        friendly_title: 'Northern Territory Reserved Block',
        state: 'NT',
        type: 'electricity',
        includes: [
          /^(250\d{7})$/
        ],
        excludes: [
        ]
      },
      'ERGONETP' => {
        title: 'Ergon Energy Corporation',
        friendly_title: 'Ergon Energy',
        state: 'QLD',
        type: 'electricity',
        includes: [
          /^(QAAA[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(QCCC[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(QDDD[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(QEEE[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(QFFF[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(QGGG[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(30\d{8})$/
        ],
        excludes: [
        ]
      },
      'ENERGEXP' => {
        title: 'ENERGEX Limited',
        friendly_title: 'Energex',
        state: 'QLD',
        type: 'electricity',
        includes: [
          /^(QB\d{2}[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(31\d{8})$/
        ],
        excludes: [
        ]
      },
      'PLINKP' => {
        title: 'Qld Electricity Transmission Corp (Powerlink)',
        friendly_title: 'Powerlink',
        state: 'QLD',
        type: 'electricity',
        includes: [
          /^(Q[A-HJ-NP-Z\d]{3}W[A-HJ-NP-Z\d]{5})$/,
          /^(320200\d{4})$/
        ],
        excludes: [
        ]
      },
      'UMPLP' => {
        title: 'SA Power Networks',
        friendly_title: 'SA Power Networks',
        state: 'SA',
        type: 'electricity',
        includes: [
          /^(SAAA[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(SASMPL[\d]{4})$/,
          /^(200[12]\d{6})$/
        ],
        excludes: [
        ]
      },
      'ETSATP' => {
        title: 'ElectraNet SA',
        friendly_title: 'ElectraNet SA',
        state: 'SA',
        type: 'electricity',
        includes: [
          /^(S[A-HJ-NP-Z\d]{3}W[A-HJ-NP-Z\d]{5})$/,
          /^(210200\d{4})$/
        ],
        excludes: [
        ]
      },
      'AURORAP' => {
        title: 'TasNetworks',
        friendly_title: 'TasNetworks',
        state: 'TAS',
        type: 'electricity',
        includes: [
          /^(T000000(([0-4]\d{3})|(500[01])))$/,
          /^(8000\d{6})$/,
          /^(8590[23]\d{5})$/
        ],
        excludes: [
        ]
      },
      'TRANSEND' => {
        title: 'TasNetworks',
        friendly_title: 'TasNetworks',
        state: 'TAS',
        type: 'electricity',
        includes: [
          /^(T[A-HJ-NP-Z\d]{3}W[A-HJ-NP-Z\d]{5})$/
        ],
        excludes: [
        ]
      },
      'CITIPP' => {
        title: 'CitiPower',
        friendly_title: 'CitiPower',
        state: 'VIC',
        type: 'electricity',
        includes: [
          /^(VAAA[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(610[23]\d{6})$/
        ],
        excludes: [
        ]
      },
      'EASTERN' => {
        title: 'SP AusNet',
        friendly_title: 'SP AusNet DNSP',
        state: 'VIC',
        type: 'electricity',
        includes: [
          /^(VBBB[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(630[56]\d{6})$/
        ],
        excludes: [
        ]
      },
      'POWCP' => {
        title: 'PowerCor Australia',
        friendly_title: 'PowerCor',
        state: 'VIC',
        type: 'electricity',
        includes: [
          /^(VCCC[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(620[34]\d{6})$/
        ],
        excludes: [
        ]
      },
      'SOLARISP' => {
        title: 'Jemena  Electricity Networks (VIC)',
        friendly_title: 'Jemena',
        state: 'VIC',
        type: 'electricity',
        includes: [
          /^(VDDD[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(6001\d{6})$/
        ],
        excludes: [
        ]
      },
      'UNITED' => {
        title: 'United Energy Distribution',
        friendly_title: 'United Energy',
        state: 'VIC',
        type: 'electricity',
        includes: [
          /^(VEEE[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(640[78]\d{6})$/
        ],
        excludes: [
        ]
      },
      'GPUPP' => {
        title: 'SP AusNet TNSP',
        friendly_title: 'SP AusNet TNSP',
        state: 'VIC',
        type: 'electricity',
        includes: [
          /^(V[A-HJ-NP-Z\d]{3}W[A-HJ-NP-Z\d]{5})$/,
          /^(650900\d{4})$/
        ],
        excludes: [
        ]
      },
      'WESTERNPOWER' => {
        title: 'Western Power',
        friendly_title: 'Western Power',
        state: 'WA',
        type: 'electricity',
        includes: [
          /^(WAAA[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(800[1-9]\d{6})$/,
          /^(801\d{7})$/,
          /^(8020\d{6})$/
        ],
        excludes: [
        ]
      },
      'HORIZONPOWER' => {
        title: 'Horizon Power',
        friendly_title: 'Horizon Power',
        state: 'WA',
        type: 'electricity',
        includes: [
          /^(8021\d{6})$/
        ],
        excludes: [
        ]
      },
      'GAS_NSW' => {
        title: 'GAS NSW',
        friendly_title: 'GAS NSW',
        state: 'NSW',
        type: 'gas',
        includes: [
          /^(52\d{8})$/
        ],
        excludes: [
        ]
      },
      'GAS_VIC' => {
        title: 'GAS VIC',
        friendly_title: 'GAS VIC',
        state: 'VIC',
        type: 'gas',
        includes: [
          /^(53\d{8})$/
        ],
        excludes: [
        ]
      },
      'GAS_QLD' => {
        title: 'GAS QLD',
        friendly_title: 'GAS QLD',
        state: 'QLD',
        type: 'gas',
        includes: [
          /^(54\d{8})$/
        ],
        excludes: [
        ]
      },
      'GAS_SA' => {
        title: 'GAS SA',
        friendly_title: 'GAS SA',
        state: 'SA',
        type: 'gas',
        includes: [
          /^(55\d{8})$/
        ],
        excludes: [
        ]
      },
      'GAS_WA' => {
        title: 'GAS WA',
        friendly_title: 'GAS WA',
        state: 'WA',
        type: 'gas',
        includes: [
          /^(56\d{8})$/
        ],
        excludes: [
        ]
      },
      'GAS_TAS' => {
        title: 'GAS TAS',
        friendly_title: 'GAS TAS',
        state: 'TAS',
        type: 'gas',
        includes: [
          /^(57\d{8})$/
        ],
        excludes: [
        ]
      },
      'FEDAIRPORTS' => {
        title: 'Federal Airports Corporation (Sydney Airport)',
        friendly_title: 'Sydney Airport',
        state: 'NSW',
        type: 'electricity',
        includes: [
          /^(NJJJNR[A-HJ-NP-Z\d]{4})$/
        ],
        excludes: [
        ]
      },
      'EXEMPTNETWORKS' => {
        title: 'Exempt Networks - various',
        friendly_title: 'Exempt Networks - various',
        state: '',
        type: 'electricity',
        includes: [
          /^(NKKK[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
          /^(7102\d{6})$/
        ],
        excludes: [
        ]
      },
      'AEMORESERVED' => {
        title: 'AEMO Reserved',
        friendly_title: 'AEMO Reserved',
        state: '',
        type: 'electricity',
        includes: [
          /^(880[1-5]\d{6})$/,
          /^(9\d{9})$/
        ],
        excludes: [
        ]
      }
    }.freeze
  end
end
