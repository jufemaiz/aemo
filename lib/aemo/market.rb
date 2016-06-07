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
      def current_dispatch(region)
        response = get "/mms.GRAPHS/GRAPHS/GRAPH_5#{region}1.csv"
        values = parse_response(response)
        values
      end

      def current_trading(region)
        response = get "/mms.GRAPHS/GRAPHS/GRAPH_30#{region}1.csv"
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
            values.push ::AEMO::Market::Interval.parse_csv(row)
          end
        end
        values
      end
    end
  end
end
