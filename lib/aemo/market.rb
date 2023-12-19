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
      # @return [Array<AEMO::Market::Interval>] the current dispatch data
      def current_dispatch(region)
        region = AEMO::Region.new(region) if region.is_a?(String)

        response = get "/mms.GRAPHS/GRAPHS/GRAPH_5#{region}1.csv"
        parse_response(response)
      end

      # Description of method
      #
      # @param [String, AEMO::Region] region AEMO::Region
      # @return [Array<AEMO::Market::Interval>] the current trading data
      def current_trading(region)
        region = AEMO::Region.new(region) if region.is_a?(String)

        response = get "/mms.GRAPHS/GRAPHS/GRAPH_30#{region}1.csv"
        parse_response(response)
      end

      # Return an array of historic trading values based on a start and finish
      #
      # @param [String, AEMO::Region] region AEMO::Region
      # @param [Time] start this is inclusive not exclusive
      # @param [Time] finish this is inclusive not exclusive
      # @return [Array<AEMO::Market::Interval>]
      def historic_trading_by_range(region, start, finish)
        region = AEMO::Region.new(region) if region.is_a?(String)

        required_data = []
        (start..finish).map { |d| { year: d.year, month: d.month } }
                       .uniq.each do |period|
          required_data += historic_trading(region, period[:year],
                                            period[:month])
        end

        required_data.select do |values|
          values.datetime >= start && values.datetime <= finish
        end
      end

      # Return an array of historic trading values for a Year, Month and Region
      #   As per the historical data from AEMO
      #
      # @param [String, AEMO::Region] region AEMO::Region
      # @param [Integer] year The year for the report from AEMO
      # @param [Integer] month The month for the report from AEMO
      # @return [Array<AEMO::Market::Interval>]
      def historic_trading(region, year, month)
        region = AEMO::Region.new(region) if region.is_a?(String)

        month = Kernel.format('%02d', month)
        url = 'https://aemo.com.au/aemo/data/nem/priceanddemand/' \
              "PRICE_AND_DEMAND_#{year}#{month}_#{region}1.csv"

        response = HTTParty.get(url)
        parse_response(response)
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
