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

    def initialize(region)
      if is_valid_region?(region)
        @region = region
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
  
    protected
  
    def is_valid_region?(region)
      REGIONS.keys.include?(region)
    end
  
  end

end