require 'pdk'

module PDK
  module PluginTypes
    class Generator < Plugin
      attr_reader :object_type

      attr_reader :puppet_strings_type

      # @abstract
      # @return [Class] That inherits from ::Logger
      def generator_klass; end

      def activate!
        return if activated?
        instance = generator_klass.new
        @object_type = instance.object_type
        @puppet_strings_type = instance.puppet_strings_type
        super
      end
    end
  end
end
