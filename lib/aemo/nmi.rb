module AEMO
  class NMI
    REGIONS = {
      'ACT' => 'Australian Capital Territory',
      'NSW' => 'New South Wales',
      'QLD' => 'Queensland',
      'SA'  => 'South Australia',
      'TAS' => 'Tasmania',
      'VIC' => 'Victoria',
      'WA'  => 'Western Australia',
      'NT'  => 'Northern Territory'
    }
    NETWORK_SERVICE_PROVIDERS = [
      # ACT
      {
        type: 'electrical',
        key: 'ACTEWP',
        states: ['ACT'],
        names: ['Actew Distribution Ltd','Jemena Networks (ACT) Pty Ltd'],
        nmi_blocks: [
          /^NGGG[A-HJ-NP-VX-Z0-9][A-HJ-NP-Z0-9]{5}$/,
          /^7001[0-9]{6}$/
        ]
      },
      # NSW
      {
        type: 'electrical',
        key: 'ENERGYAP',
        states: ['NSW'],
        names: ['Ausgrid'],
        nmi_blocks: [
          /^NTTT[A-HJ-NP-VX-Z0-9][A-HJ-NP-Z0-9]{5}$/,
          /^410[2-4][0-9]{6}$/
        ]
      },
      {
        type: 'electrical',
        key: 'INTEGP',
        states: ['NSW'],
        names: ['Endeavour Energy'],
        nmi_blocks: [
          /^NEEE[A-HJ-NP-VX-Z0-9][A-HJ-NP-Z0-9]{5}$/,
          /^431[0-9][0-9]{6}$/
        ]
      },
      {
        type: 'electrical',
        key: 'CNRGYP',
        states: ['NSW'],
        names: ['Essential Energy'],
        nmi_blocks: [
          /^NAAA[A-HJ-NP-VX-Z0-9][A-HJ-NP-Z0-9]{5}$/,
          /^NBBB[A-HJ-NP-VX-Z0-9][A-HJ-NP-Z0-9]{5}$/,
          /^NDDD[A-HJ-NP-VX-Z0-9][A-HJ-NP-Z0-9]{5}$/,
          /^NFFF[A-HJ-NP-VX-Z0-9][A-HJ-NP-Z0-9]{5}$/,
          /^4001[0-9]{6}$/,
          /^4508[0-9]{6}$/,
          /^4204[0-9]{6}$/,
          /^4407[0-9]{6}$/
        ]
      },
      {
        type: 'electrical',
        key: 'TRANSGP',
        states: ['NSW'],
        names: ['TransGrid'],
        nmi_blocks: [
          /^NCCC[A-HJ-NP-VX-Z0-9][A-HJ-NP-Z0-9]{5}$/,
          /^410[2-4][0-9]{6}$/
        ]
      },
      {
        type: 'electrical',
        key: 'SNOWY',
        states: ['NSW'],
        names: ['Snowy Hydro'],
        nmi_blocks: [
          /^4708109[0-9]{3}$/
        ]
      },
      # NT
      {
        type: 'electrical',
        key: 'RESERVED_NT',
        states: ['NT'],
        names: [],
        nmi_blocks: [
          /^250[0-9]{7}$/
        ]
      },
      # QUEENSLAND
      {
        type: 'electrical',
        key: 'ERGONETP',
        states: ['QLD'],
        names: ['Ergon Energy'],
        nmi_blocks: [
          /^QAAA[A-HJ-NP-VX-Z0-9][A-HJ-NP-Z0-9]{5}$/,
          /^QCCC[A-HJ-NP-VX-Z0-9][A-HJ-NP-Z0-9]{5}$/,
          /^QDDD[A-HJ-NP-VX-Z0-9][A-HJ-NP-Z0-9]{5}$/,
          /^QEEE[A-HJ-NP-VX-Z0-9][A-HJ-NP-Z0-9]{5}$/,
          /^QFFF[A-HJ-NP-VX-Z0-9][A-HJ-NP-Z0-9]{5}$/,
          /^QGGG[A-HJ-NP-VX-Z0-9][A-HJ-NP-Z0-9]{5}$/,
          /^30[0-9]{8}$/
        ]
      },
      {
        type: 'electrical',
        key: 'ENERGEXP',
        states: ['QLD'],
        names: ['ENERGEX'],
        nmi_blocks: [
          /^QB[0-9]{2}[A-HJ-NP-VX-Z0-9][A-HJ-NP-Z0-9]{5}$/,
          /^31[0-9]{8}$/
        ]
      },
      {
        type: 'electrical',
        key: 'PLINKP',
        states: ['QLD'],
        names: ['QLD Electricity Transmission Corp (Powerlink)'],
        nmi_blocks: [
          /^QtniW[A-HJ-NP-Z0-9]{5}$/,
          /^320200[0-9]{4}$/
        ]
      },
      # SA
      {
        type: 'electrical',
        key: 'UMPLP',
        states: ['SA'],
        names: ['SA Power Networks'],
        nmi_blocks: [
          /^SAAA[A-HJ-NP-VX-Z0-9][A-HJ-NP-Z0-9]{5}$/,
          /^SASMPL[0-9]{4}$/,
          /^200[1-2][0-9]{6}$/
        ]
      },
      {
        type: 'electrical',
        key: 'ETSATP',
        states: ['SA'],
        names: ['ElectraNet'],
        nmi_blocks: [
          /^StniW[A-HJ-NP-Z0-9]{5}$/,
          /^310200[0-9]{4}$/
        ]
      },
      # TASMANIA
      {
        type: 'electrical',
        key: 'AURORAP',
        states: ['TAS'],
        names: ['Aurora Energy'],
        nmi_blocks: [
          /^T00000(([0-4][0-9]{3})|(5001))$/,
          /^8000[0-9]{6}$/,
          /^8590[2-3][0-9]{5}$/
        ]
      },
      {
        type: 'electrical',
        key: 'TRANSEND',
        states: ['TAS'],
        names: ['Transend Networks'],
        nmi_blocks: [
          /^TtniW[A-HJ-NP-Z0-9]{5}$/
        ]
      },
      # VICTORIA
      {
        type: 'electrical',
        key: 'CITIPP',
        states: ['VIC'],
        names: ['CitiPower'],
        nmi_blocks: [
          /^VAAA[A-HJ-NP-VX-Z0-9][A-HJ-NP-Z0-9]{5}$/,
          /^610[2-3][0-9]{6}$/
        ]
      },
      {
        type: 'electrical',
        key: 'EASTERN',
        states: ['VIC'],
        names: ['AusNet'],
        nmi_blocks: [
          /^VBBB[A-HJ-NP-VX-Z0-9][A-HJ-NP-Z0-9]{5}$/,
          /^630[5-6][0-9]{6}$/
        ]
      },
      {
        type: 'electrical',
        key: 'POWCP',
        states: ['VIC'],
        names: ['Powercor'],
        nmi_blocks: [
          /^VCCC[A-HJ-NP-VX-Z0-9][A-HJ-NP-Z0-9]{5}$/,
          /^620[3-4][0-9]{6}$/
        ]
      },
      {
        type: 'electrical',
        key: 'Jemena Electricity Networks',
        states: ['VIC'],
        names: ['SOLARISP'],
        nmi_blocks: [
          /^VDDD[A-HJ-NP-VX-Z0-9][A-HJ-NP-Z0-9]{5}$/,
          /^6001[0-9]{6}$/
        ]
      },
      {
        type: 'electrical',
        key: 'UNITED',
        states: ['VIC'],
        names: ['United Energy Distribution'],
        nmi_blocks: [
          /^VEEE[A-HJ-NP-VX-Z0-9][A-HJ-NP-Z0-9]{5}$/,
          /^640[7-8][0-9]{6}$/
        ]
      },
      {
        type: 'electrical',
        key: 'GPUPP',
        states: ['SA'],
        names: ['AusNet'],
        nmi_blocks: [
          /^VtniW[A-HJ-NP-Z0-9]{5}$/,
          /^650900[0-9]{4}$/
        ]
      },
      # WA
      {
        type: 'electrical',
        key: 'WESTERNPOWER',
        states: ['WA'],
        names: ['Western Power'],
        nmi_blocks: [
          /^WAAA[A-HJ-NP-VX-Z0-9][A-HJ-NP-Z0-9]{5}$/,
          /^801[0-9]{7}$/,
          /^8020[0-9]{6}$/
        ]
      },
      {
        type: 'electrical',
        key: 'GPUPP',
        states: ['SA'],
        names: ['AusNet'],
        nmi_blocks: [
          /^8021[0-9]{6}$/
        ]
      },
      # GAS
      {
        type: 'gas',
        key: nil,
        states: ['NSW','ACT'],
        names: [],
        nmi_blocks: [
          /^52[0-9]{8}$/
        ]
      },
      {
        type: 'gas',
        key: nil,
        states: ['VIC'],
        names: [],
        nmi_blocks: [
          /^53[0-9]{8}$/
        ]
      },
      {
        type: 'gas',
        key: nil,
        states: ['QLD'],
        names: [],
        nmi_blocks: [
          /^54[0-9]{8}$/
        ]
      },
      {
        type: 'gas',
        key: nil,
        states: ['SA'],
        names: [],
        nmi_blocks: [
          /^55[0-9]{8}$/
        ]
      },
      {
        type: 'gas',
        key: nil,
        states: ['WA'],
        names: [],
        nmi_blocks: [
          /^56[0-9]{8}$/
        ]
      },
      {
        type: 'gas',
        key: nil,
        states: ['TAS'],
        names: [],
        nmi_blocks: [
          /^57[0-9]{8}$/
        ]
      },
      # MISC
      {
        type: 'electrical',
        key: nil,
        states: [],
        names: ['Federal Airports Corporation (Sydney Airport)'],
        nmi_blocks: [
          /^NJJJNR[A-HJ-NP-Z0-9]{4}$/
        ]
      },
      {
        type: 'electrical',
        key: nil,
        states: [],
        names: ['Exempt Networks - various'],
        nmi_blocks: [
          /^NKKKNR[A-HJ-NP-Z0-9]{4}$/,
          /^7102[0-9]{6}$/
        ]
      },
      {
        type: 'electrical',
        key: nil,
        states: [],
        names: ['AEMO Reserved Block 1'],
        nmi_blocks: [
          /^880[1-5][0-9]{6}$/
        ]
      },
      {
        type: 'electrical',
        key: nil,
        states: [],
        names: ['AEMO Reserved Block 1'],
        nmi_blocks: [
          /^9[0-9]{9}$/
        ]
      }
    ]
    
    attr_accessor :region

    def initialize(nmi)
      @nmi = nmi
      @network = NMI.find_network(nmi)
    end
    
    
    def self.find_network(nmi)
      nmi_network = nil
      NETWORK_SERVICE_PROVIDERS.each do |network|
        network[:nmi_blocks].each do |nmi_block|
          nmi_network = network if nmi.match(nmi_block)
        end
        break unless nmi_network.nil?
      end
      nmi_network
    end
    
    # ######### #
      protected
    # ######### #
  
    def is_valid_region?(region)
      REGIONS.keys.include?(region)
    end
  
  end
end