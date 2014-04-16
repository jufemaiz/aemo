module AEMO
  module Market
    class Interval

      def initialize(datetime,options={})
        @datetime   = datetime
        @region     = options['REGION']
        @demand     = options['TOTALDEMAND']
        @rrp        = options['RRP']
        @periodtype = options['PERIODTYPE']
      end
  
      def value
        @demand * @rrp
      end

    end
  end
end