# frozen_string_literal: true

module AEMO
  # AEMO::Region
  #
  # @author Joel Courtney
  # @abstract
  # @since 0.1.0
  class Region
    # Regions under juristiction
    REGIONS = {
      'ACT' => 'Australian Capital Territory',
      'NSW' => 'New South Wales',
      'QLD' => 'Queensland',
      'SA' => 'South Australia',
      'TAS' => 'Tasmania',
      'VIC' => 'Victoria',
      'NT' => 'Northern Territory',
      'WA' => 'Western Australia'
    }.freeze

    attr_accessor :region
    attr_reader :aemo_market_node

    class << self
      def all
        REGIONS.keys.map { |k| AEMO::Region.new(k) }
      end
    end

    # Create a new instance of AEMO::Region
    #
    # @param [String] region State
    # @return [self]
    def initialize(region)
      raise ArgumentError, "Region '#{region}' is not valid." unless valid_region?(region)

      @region = region.upcase
      @full_name = REGIONS[@region]
      @current_trading = []
      @current_dispatch = []
      @aemo_market_node = if %w[NSW QLD SA TAS VIC].include?(@region)
                            AEMO::Market::Node.new(region)
                          elsif @region == 'ACT'
                            AEMO::Market::Node.new('NSW')
                          end
    end

    # Abbreviation method
    #
    # @return [String]
    def abbr
      @region
    end

    # @return [String]
    def to_s
      @region
    end

    # @return [String]
    def fullname
      REGIONS[@region]
    end

    # Return the current dispatch data
    #
    # @return [Array<AEMO::Market::Interval>]
    def current_dispatch
      @aemo_market_node.current_dispatch
    end

    # Return the current trading data
    #
    # @return [Array<AEMO::Market::Interval>]
    def current_trading
      @aemo_market_node.current_trading
    end

    protected

    # Validates a region
    #
    # @param [String] region
    # @return [Boolean]
    def valid_region?(region)
      REGIONS.keys.include?(region.upcase)
    end
  end
end
