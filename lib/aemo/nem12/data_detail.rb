module AEMO
  module NEM12
    # This class represents a data detail record. This record contains the META information
    # related to the sub sequent records and applies until another data detail record occurs.
    class DataDetail < Record
      def interval_count
        1440 / interval_length.to_i
      end

      def match?(options)
        options.all? do |key, value|
          self.public_send(key.to_sym) == value
        end
      end
    end
  end
end
