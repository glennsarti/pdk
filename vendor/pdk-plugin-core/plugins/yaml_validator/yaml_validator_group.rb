require 'pdk'

module PDK
  module Validate
    class YAMLValidatorGroup < ValidatorGroup
      def name
        'yaml'
      end

      def validators
        [PDK::Validate::YAMLSyntax].freeze
      end
    end
  end
end
