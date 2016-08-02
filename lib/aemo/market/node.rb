module AEMO
  module Market
    # AEMO::Market::Interval
    #
    # @author Joel Courtney
    # @abstract
    # @since 0.1.0
    class Node
      IDENTIFIERS = %w(NSW QLD SA TAS VIC)

      attr_accessor :identifier

      def initialize(identifier)
        raise ArgumentError, "Node Identifier '#{identifier}' is not valid." unless IDENTIFIERS.include?(identifier.upcase)
        @identifier = identifier
        @current_trading = []
        @current_dispatch = []
      end

      # Return the current dispatch data
      #
      # @return [Array<AEMO::Market::Interval>]
      def current_dispatch
        if @current_dispatch.empty? || @current_dispatch.last.datetime != (Time.now - Time.now.to_i % 300)
          @current_dispatch = AEMO::Market.current_dispatch(@identifier)
        end
        @current_dispatch
      end

      # Return the current trading data
      #
      # @return [Array<AEMO::Market::Interval>]
      def current_trading
        if @current_trading.empty? || @current_trading.reject { |i| i.period_type != 'TRADE' }.last.datetime != (Time.now - Time.now.to_i % 300)
          @current_trading = AEMO::Market.current_trading(@identifier)
        end
        @current_trading
      end
    end
  end
end
