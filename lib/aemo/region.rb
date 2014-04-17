module AEMO
  class Region
    REGIONS = {
      'ACT' => 'Australian Capital Territory',
      'NSW' => 'New South Wales',
      'QLD' => 'Queensland',
      'SA'  => 'South Australia',
      'TAS' => 'Tasmania',
      'VIC' => 'Victoria'
    }
    
    attr_accessor :region

    def initialize(region)
      if is_valid_region?(region)
        @region = region
        @current_trading = []
        @current_dispatch = []
      end
    end
  
    def abbr
      @region
    end
  
    def to_s
      @region
    end
  
    def fullname
      REGIONS[@region]
    end
    
    def current_dispatch
      if @current_dispatch.length == 0 || @current_dispatch.last.datetime != (Time.now - Time.now.to_i % 300)
        @current_dispatch = AEMO::Market.current_dispatch(@region)
      end
      @current_dispatch
    end
    
    def current_trading
      if @current_trading.length == 0 || @current_trading.reject{|i| i.period_type != 'TRADE'}.last.datetime != (Time.now - Time.now.to_i % 300)
        @current_trading = AEMO::Market.current_trading(@region)
      end
      @current_trading
    end
    
    def self.all
      REGIONS.keys.map{|k| AEMO::Region.new(k)}
    end
  
    # ######### #
      protected
    # ######### #
  
    def is_valid_region?(region)
      REGIONS.keys.include?(region)
    end
  
  end
end