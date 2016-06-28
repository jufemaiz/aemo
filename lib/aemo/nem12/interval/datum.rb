# Record Indicator: 300 - each individual interval
#
# @author Joel Courtney
# @abstract
# @since 0.2.0
# @attr [DateTime] rising_edge Rising DateTime of the period for the value
# @attr [DateTime] trailing_edge Trailing DateTime of the period for the value
# @attr [Integer] interval_number The interval of the day that the period is for
# @attr [Integer] period The period in whole minutes for the value
# @attr [Float] value The value
# @attr [Flag] to_participant The recipient of the NEM12 file
module AEMO
  class NEM12
    class Interval
      class Datum
      end
    end
  end
end
