require 'pdk/plugin_manager'

module PDK
  module PluginTypes
    class Plugin
      attr_reader :name

      def initialize(name)
        @name = name.to_s
        @activated = false
      end

      def plugin_metadata
        @plugin_metadata ||= PDK::PluginManager.instance.plugin_metadata(name)
      end

      def plugin_dependencies
        return [] if plugin_metadata['dependencies'].nil?
        plugin_metadata['dependencies']
      end

      def activated?
        @activated
      end

      def activate!
        @activated = true
# DEBUG
puts("Activated PDK Plugin #{name}")
      end
    end
  end
end
