# frozen_string_literal: true

module AEMO
  class NMI
    # AEMO::NMI::Allocation
    #
    # @author Joel Courtney
    # @author Stuart Auld
    # @abstract An abstraction of NMI Allocation groups that kind of represents networks but not always.
    # @since 0.3.0
    class Allocation
      # NMI_ALLOCATIONS as per AEMO Documentation at
      # hhttps://www.aemo.com.au/-/media/Files/Electricity/NEM/Retail_and_Metering/Metering-Procedures/NMI-Allocation-List.pdf
      # Last updated 2017-08-01
      ALLOCATIONS = [
        {
          participant_id: 'ACTEWP',
          title: 'Actew Distribution Ltd and Jemena Networks (ACT) Pty Ltd',
          friendly_title: 'ACTEWAgl',
          region: 'ACT',
          type: 'electricity',
          includes: [
            /^(NGGG[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
            /^(7001\d{6})$/
          ],
          excludes: []
        },
        {
          participant_id: 'CNRGYP',
          title: 'Essential Energy',
          friendly_title: 'Essential Energy',
          region: 'NSW',
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
          excludes: []
        },
        {
          participant_id: 'ENERGYAP',
          title: 'Ausgrid',
          friendly_title: 'Ausgrid',
          region: 'NSW',
          type: 'electricity',
          includes: [
            /^(NCCC[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
            /^(410[234]\d{6})$/
          ],
          excludes: []
        },
        {
          participant_id: 'INTEGP',
          title: 'Endeavour Energy',
          friendly_title: 'Endeavour Energy',
          region: 'NSW',
          type: 'electricity',
          includes: [
            /^(NEEE[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
            /^(431\d{7})$/
          ],
          excludes: []
        },
        {
          participant_id: 'TRANSGP',
          title: 'TransGrid',
          friendly_title: 'TransGrid',
          region: 'NSW',
          type: 'electricity',
          includes: [
            /^(NTTT[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
            /^(460810[0-8]\d{3})$/
          ],
          excludes: []
        },
        {
          participant_id: 'SNOWY',
          title: 'Snowy Hydro Ltd',
          friendly_title: 'Snowy Hydro',
          region: 'NSW',
          type: 'electricity',
          includes: [/^(4708109\d{3})$/],
          excludes: []
        },
        {
          participant_id: 'NT_RESERVED',
          title: 'Northern Territory Reserved Block',
          friendly_title: 'Northern Territory Reserved Block',
          region: 'NT',
          type: 'electricity',
          includes: [/^(250\d{7})$/],
          excludes: []
        },
        {
          participant_id: 'ERGONETP',
          title: 'Ergon Energy Corporation',
          friendly_title: 'Ergon Energy',
          region: 'QLD',
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
          excludes: []
        },
        {
          participant_id: 'ENERGEXP',
          title: 'ENERGEX Limited',
          friendly_title: 'Energex',
          region: 'QLD',
          type: 'electricity',
          includes: [
            /^(QB\d{2}[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
            /^(31\d{8})$/
          ],
          excludes: []
        },
        {
          participant_id: 'PLINKP',
          title: 'Qld Electricity Transmission Corp (Powerlink)',
          friendly_title: 'Powerlink',
          region: 'QLD',
          type: 'electricity',
          includes: [
            /^(Q[A-HJ-NP-Z\d]{3}W[A-HJ-NP-Z\d]{5})$/,
            /^(320200\d{4})$/
          ],
          excludes: []
        },
        {
          participant_id: 'UMPLP',
          title: 'SA Power Networks',
          friendly_title: 'SA Power Networks',
          region: 'SA',
          type: 'electricity',
          includes: [
            /^(SAAA[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
            /^(SASMPL[\d]{4})$/,
            /^(200[12]\d{6})$/
          ],
          excludes: []
        },
        {
          participant_id: 'ETSATP',
          title: 'ElectraNet SA',
          friendly_title: 'ElectraNet SA',
          region: 'SA',
          type: 'electricity',
          includes: [
            /^(S[A-HJ-NP-Z\d]{3}W[A-HJ-NP-Z\d]{5})$/,
            /^(210200\d{4})$/
          ],
          excludes: []
        },
        {
          participant_id: 'AURORAP',
          title: 'TasNetworks',
          friendly_title: 'TasNetworks',
          region: 'TAS',
          type: 'electricity',
          includes: [
            /^(T000000(([0-4]\d{3})|(500[01])))$/,
            /^(8000\d{6})$/,
            /^(8590[23]\d{5})$/
          ],
          excludes: []
        },
        {
          participant_id: 'TRANSEND',
          title: 'TasNetworks',
          friendly_title: 'TasNetworks',
          region: 'TAS',
          type: 'electricity',
          includes: [/^(T[A-HJ-NP-Z\d]{3}W[A-HJ-NP-Z\d]{5})$/],
          excludes: []
        },
        {
          participant_id: 'CITIPP',
          title: 'CitiPower',
          friendly_title: 'CitiPower',
          region: 'VIC',
          type: 'electricity',
          includes: [
            /^(VAAA[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
            /^(610[23]\d{6})$/
          ],
          excludes: []
        },
        {
          participant_id: 'EASTERN',
          title: 'SP AusNet',
          friendly_title: 'SP AusNet DNSP',
          region: 'VIC',
          type: 'electricity',
          includes: [
            /^(VBBB[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
            /^(630[56]\d{6})$/
          ],
          excludes: []
        },
        {
          participant_id: 'POWCP',
          title: 'PowerCor Australia',
          friendly_title: 'PowerCor',
          region: 'VIC',
          type: 'electricity',
          includes: [
            /^(VCCC[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
            /^(620[34]\d{6})$/
          ],
          excludes: []
        },
        {
          participant_id: 'SOLARISP',
          title: 'Jemena  Electricity Networks (VIC)',
          friendly_title: 'Jemena',
          region: 'VIC',
          type: 'electricity',
          includes: [
            /^(VDDD[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
            /^(6001\d{6})$/
          ],
          excludes: []
        },
        {
          participant_id: 'UNITED',
          title: 'United Energy Distribution',
          friendly_title: 'United Energy',
          region: 'VIC',
          type: 'electricity',
          includes: [
            /^(VEEE[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
            /^(640[78]\d{6})$/
          ],
          excludes: []
        },
        {
          participant_id: 'GPUPP',
          title: 'SP AusNet TNSP',
          friendly_title: 'SP AusNet TNSP',
          region: 'VIC',
          type: 'electricity',
          includes: [
            /^(V[A-HJ-NP-Z\d]{3}W[A-HJ-NP-Z\d]{5})$/,
            /^(650900\d{4})$/
          ],
          excludes: []
        },
        {
          participant_id: 'WESTERNPOWER',
          title: 'Western Power',
          friendly_title: 'Western Power',
          region: 'WA',
          type: 'electricity',
          includes: [
            /^(WAAA[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
            /^(800[1-9]\d{6})$/,
            /^(801\d{7})$/,
            /^(8020\d{6})$/
          ],
          excludes: []
        },
        {
          participant_id: 'HORIZONPOWER',
          title: 'Horizon Power',
          friendly_title: 'Horizon Power',
          region: 'WA',
          type: 'electricity',
          includes: [/^(8021\d{6})$/],
          excludes: []
        },
        {
          participant_id: 'GAS_NSW',
          title: 'GAS NSW',
          friendly_title: 'GAS NSW',
          region: 'NSW',
          type: 'gas',
          includes: [/^(52\d{8})$/],
          excludes: []
        },
        {
          participant_id: 'GAS_VIC',
          title: 'GAS VIC',
          friendly_title: 'GAS VIC',
          region: 'VIC',
          type: 'gas',
          includes: [/^(53\d{8})$/],
          excludes: []
        },
        {
          participant_id: 'GAS_QLD',
          title: 'GAS QLD',
          friendly_title: 'GAS QLD',
          region: 'QLD',
          type: 'gas',
          includes: [/^(54\d{8})$/],
          excludes: []
        },
        {
          participant_id: 'GAS_SA',
          title: 'GAS SA',
          friendly_title: 'GAS SA',
          region: 'SA',
          type: 'gas',
          includes: [/^(55\d{8})$/],
          excludes: []
        },
        {
          participant_id: 'GAS_WA',
          title: 'GAS WA',
          friendly_title: 'GAS WA',
          region: 'WA',
          type: 'gas',
          includes: [/^(56\d{8})$/],
          excludes: []
        },
        {
          participant_id: 'GAS_TAS',
          title: 'GAS TAS',
          friendly_title: 'GAS TAS',
          region: 'TAS',
          type: 'gas',
          includes: [/^(57\d{8})$/],
          excludes: []
        },
        {
          participant_id: 'FEDAIRPORTS',
          title: 'Federal Airports Corporation (Sydney Airport)',
          friendly_title: 'Sydney Airport',
          region: 'NSW',
          type: 'electricity',
          includes: [/^(NJJJNR[A-HJ-NP-Z\d]{4})$/],
          excludes: []
        },
        {
          participant_id: 'EXEMPTNETWORKS',
          title: 'Exempt Networks - various',
          friendly_title: 'Exempt Networks - various',
          type: 'electricity',
          includes: [
            /^(NKKK[A-HJ-NP-VX-Z\d][A-HJ-NP-Z\d]{5})$/,
            /^(7102\d{6})$/
          ],
          excludes: []
        },
        {
          participant_id: 'AEMORESERVED',
          title: 'AEMO Reserved',
          friendly_title: 'AEMO Reserved',
          type: 'electricity',
          includes: [
            /^(880[1-5]\d{6})$/,
            /^(9\d{9})$/
          ],
          excludes: []
        }
      ].freeze

      SUPPORTED_TYPES = %i[electricity gas].freeze

      attr_accessor :exclude_nmi_patterns,
                    :friendly_title,
                    :identifier,
                    :include_nmi_patterns,
                    :region,
                    :title,
                    :type

      alias state region
      alias state= region=

      class << self
        include Enumerable

        # Return all the NMI allocations
        #
        # @return [Array<AEMO::NMI::Allocation>]
        def all
          ALLOCATIONS.map do |a|
            new(a.fetch(:title), a.fetch(:type), a)
          end
        end

        # Enumerable support
        #
        # @return [Enumerator]
        def each(&block)
          all.each(&block)
        end

        # Finds the Allocation that encompasses a given NMI
        #
        # @param [string] nmi
        # @return [AEMO::NMI::Allocation]
        def find_by_nmi(nmi)
          each do |allocation|
            allocation.exclude_nmi_patterns.each do |pattern|
              next if nmi.match(pattern)
            end
            allocation.include_nmi_patterns.each do |pattern|
              return allocation if nmi.match(pattern)
            end
          end
          nil
        end
      end

      def initialize(title, type, opts = {})
        @title = title
        @type = parse_allocation_type(type)
        @identifier = opts.fetch(:identifier, title.upcase)
        @friendly_title = opts.fetch(:friendly_title, title)
        @exclude_nmi_patterns = opts.fetch(:excludes, [])
        @include_nmi_patterns = opts.fetch(:includes, [])
        @region = AEMO::Region.new(opts.fetch(:region)) if opts.dig(:region)
      end

      private

      def parse_allocation_type(type)
        type_sym = type.to_sym
        raise AEMO::InvalidNMIAllocationType unless SUPPORTED_TYPES.include? type_sym
        type_sym
      rescue NoMethodError
        raise AEMO::InvalidNMIAllocationType
      end
    end
  end
end
