# frozen_string_literal: true

module AEMO
  # AEMO::Market
  #
  # @author Joel Courtney
  # @abstract
  # @since 0.1.0
  module Market
    include HTTParty
    base_uri 'www.nemweb.com.au'

    # Class Methods
    class << self
      # Return the current dispatch dataset for a region
      #
      # @param [String, AEMO::Region] region AEMO::Region
      # @return [Array<AEMO::Market::Interval>] an array of AEMO::Market::Intervals
      def current_dispatch(region)
        region = AEMO::Region.new(region) if region.is_a?(String)

        response = get "/mms.GRAPHS/GRAPHS/GRAPH_5#{region}1.csv"
        values = parse_response(response)
        values
      end

      # Description of method
      #
      # @param [String, AEMO::Region] region AEMO::Region
      # @return [Array<AEMO::Market::Interval>] an array of AEMO::Market::Intervals
      def current_trading(region)
        region = AEMO::Region.new(region) if region.is_a?(String)

        response = get "/mms.GRAPHS/GRAPHS/GRAPH_30#{region}1.csv"
        values = parse_response(response)
        values
      end

      # Return an array of historic trading values based on a start and finish
      #
      # @param [String, AEMO::Region] region AEMO::Region
      # @param [DateTime] start this is inclusive not exclusive
      # @param [DateTime] finish this is inclusive not exclusive
      # @return [Array<AEMO::Market::Interval>]
      def historic_trading_by_range(region, start, finish)
        region = AEMO::Region.new(region) if region.is_a?(String)

        required_data = []
        (start..finish).map { |d| { year: d.year, month: d.month } }.uniq.each do |period|
          required_data += historic_trading(region, period[:year], period[:month])
        end

        required_data.select { |values| values.datetime >= start && values.datetime <= finish }
      end

      # Return an array of historic trading values for a Year, Month and Region
      #   As per the historical data at
      #   http://www.aemo.com.au/Electricity/Data/Price-and-Demand/Aggregated-Price-and-Demand-Data-Files/Aggregated-Price-and-Demand-2011-to-2016
      #
      # @param [String, AEMO::Region] region AEMO::Region
      # @param [Integer] year The year for the report from AEMO
      # @param [Integer] month The month for the report from AEMO
      # @return [Array<AEMO::Market::Interval>]
      def historic_trading(region, year, month)
        region = AEMO::Region.new(region) if region.is_a?(String)

        month = sprintf('%02d', month)

        response = HTTParty.get("http://aemo.com.au/aemo/data/nem/priceanddemand/PRICE_AND_DEMAND_#{year}#{month}_#{region}1.csv")
        values = parse_response(response)
        values
      end

      protected

      def parse_response(response)
        values = []
        if response.response.code == '200'
          CSV.parse(response.body, headers: true, converters: :numeric) do |row|
            if row.respond_to?(:to_h)
              row = row.to_h
            elsif row.respond_to?(:to_hash)
              row = row.to_hash
            else
              raise NoMethodError, "cannot convert #{row.class} to Hash"
            end
            values.push ::AEMO::Market::Interval.new(row['SETTLEMENTDATE'], row)
          end
        end
        values
      end
    end
  end
end
