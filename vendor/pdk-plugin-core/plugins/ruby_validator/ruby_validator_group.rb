require 'pdk'

module PDK
  module Validate
    class RubyValidatorGroup < ValidatorGroup
      def name
        'ruby'
      end

      def validators
        [RubyRubocop].freeze
      end
    end
  end
end
