module AEMO
  module Market
    include HTTParty
    base_uri 'www.nemweb.com.au'
  
    def initialize(region)
      @region = Region.new(region)
    end
  
    def self.regions
      AEMO::Region::REGIONS
    end
    
    def self.current_dispatch(region)
      response = self.class.get "/mms.GRAPHS/GRAPHS/GRAPH_5#{region}1.csv"
      values = AEMO::Market.parse_response(response)
    end

    def self.current_trading(region)
      response = self.class.get "/mms.GRAPHS/GRAPHS/GRAPH_30#{region}1.csv"
      values = AEMO::Market.parse_response(response)
    end
  
    def self.aggregated_price_and_demand(region)
      self.class.get
    end
    
    #########
    protected
    #########

    def self.parse_response(response)
      values = []
      if response.response.code == '200'
        CSV.parse(body, :headers => true, :converters => :numeric) do |row|
          row = row.to_h
          values.push AEMO::Market::Interval.new(row['SETTLEMENTDATE'],row)
        end
      end
      values
    end

  end

end

