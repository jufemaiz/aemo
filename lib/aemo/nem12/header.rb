module AEMO
  module NEM12
    # The NEM12 specification mandates the presence of a single header. This class
    # represents a single header record.
    class Header < Record
      # @return [String] the version identifier
      attr_accessor :version_identifier

      # @return [String] the file creation time
      attr_accessor :created_at

      # @return [String] the MSATS Participant ID of the MDP that generates the file
      attr_accessor :from_participant

      # @return [String] the MSATS Participant ID of the intended Registered Participant or Service Provider
      attr_accessor :to_participant

      def valid?
        version_identifier.upcase == "NEM12" && created_at.present? && from_participant.present? && to_participant.present?
      end
    end
  end
end
