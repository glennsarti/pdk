require 'pdk'

module PDK
  module PluginTypes
    class Validator < Plugin
      # @abstract
      # @return [Class] That inherits from PDK::Validate::BaseValidator
      def validator_klass; end
    end
  end
end
