require 'pdk'

module PDK
  module Build
    def self.create_builder(builder_type, source, destination, options)
      load_builder_plugins
      PDK::PluginManager.instance.plugin_names_from_type('builder').each do |plugin_name|
        plugin = PDK::PluginManager.instance[plugin_name]
        next if plugin.nil?
        return plugin.create_instance(source, destination, options) if plugin.builder_type == builder_type
      end
      nil
    end

    # @api pivoate
    # TODO: private
    def self.load_builder_plugins
      return unless @builders_loaded.nil?
      PDK::PluginManager.instance.activate_plugin_type!('builder')
      @builders_loaded = true
    end
  end
end
