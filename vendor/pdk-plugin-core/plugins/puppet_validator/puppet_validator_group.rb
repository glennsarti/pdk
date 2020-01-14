require 'pdk'

module PDK
  module Validate
    class PuppetValidatorGroup < ValidatorGroup
      def name
        'puppet'
      end

      def validators
        [PuppetSyntax, PuppetLint, PuppetEPP].freeze
      end
    end
  end
end
