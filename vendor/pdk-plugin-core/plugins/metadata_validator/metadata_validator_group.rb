require 'pdk'

module PDK
  module Validate
    class MetadataValidatorGroup < ValidatorGroup
      def name
        'metadata'
      end

      def validators
        [MetadataSyntax, MetadataJSONLint].freeze
      end
    end
  end
end
