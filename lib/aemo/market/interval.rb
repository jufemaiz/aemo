module AEMO
  module Market
    # AEMO::Market::Interval
    #
    # @author Joel Courtney
    # @abstract
    # @since 0.1.0
    class Interval
      INTERVALS = {
        trading: 'Trading',
        dispatch: 'Dispatch'
      }.freeze

      attr_accessor :datetime, :region, :total_demand, :rrp, :period_type

      # @param datetime [Time]
      # @param options [Hash] Hash of optional data values
      # @return [AEMO::Market::Interval]
      def initialize(datetime, options = {})
        @datetime     = Time.parse("#{datetime} +1000")
        @region       = options['REGION']
        @total_demand = options['TOTALDEMAND']
        @rrp          = options['RRP']
        @period_type  = options['PERIODTYPE']
      end

      # Instance Variable Getters

      # All AEMO Data operates in Australian Eastern Standard Time
      # All AEMO Data aggregates to the trailing edge of the period (this makes it difficult to do daily aggregations :( )
      # @param trailing_edge [Boolean] selection of either the trailing edge of the period or the rising edge of the period for the date time
      # @return [Time] a time object of the trailing edge of the interval
      def datetime(trailing_edge = true)
        t = @datetime
        # If the datetime requested is the trailing edge, offset as per interval requirement
        unless trailing_edge
          # This is for dispatch intervals of five minutes
          if dispatch?
            t -= 5 * 60
          elsif trading?
            t -= 30 * 60
          end
        end
        t
      end

      # @return [Time] the time of the
      def interval_length
        Time.at(300)
      end

      # @return [Symbol] :dispatch or :trading
      def interval_type
        dispatch? ? :dispatch : :trading
      end

      # @return [Boolean] returns true if the interval type is dispatch
      def dispatch?
        @period_type.nil? || @period_type.empty?
      end

      # @return [Boolean] returns true if the interval type is trading
      def trading?
        !dispatch?
      end

      # @return [Float] the value of the interval in Australian Dollars
      def value
        @value ||= Float::NAN
        if @total_demand.class == Float && @rrp.class == Float
          @value = (@total_demand * @rrp).round(2)
        end
        @value
      end
    end
  end
end
