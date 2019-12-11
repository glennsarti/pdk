require 'pdk'

module PDK
  module Generate
    autoload :Generator, 'pdk/generate/generator'
    autoload :PuppetModuleThingGenerator, 'pdk/generate/puppet_module_thing_generator'

    def self.generators
      return @generators unless @generators.nil?
      # Any core/inbuilt generators go here
      @generators = []

      PDK::PluginManager.instance.activate_plugin_type!('generator')
      PDK::PluginManager.instance.plugin_names_from_type('generator').each do |plugin_name|
        plugin = PDK::PluginManager.instance[plugin_name]
        next if plugin.nil?
        @generators << plugin.generator_klass
      end
      @generators.freeze
    end

    def self.generator_for_object_type(object_type)
      # Force the generators to be loaded
      generators if @generators.nil?
      PDK::PluginManager.instance.plugin_names_from_type('generator').each do |plugin_name|
        plugin = PDK::PluginManager.instance[plugin_name]
        next if plugin.nil?
        return plugin.generator_klass if plugin.object_type == object_type
      end
      nil
    end

    def self.generator_for_puppet_strings_type(puppet_strings_type)
      return nil if puppet_strings_type.nil?
      # Force the generators to be loaded
      generators if @generators.nil?
      PDK::PluginManager.instance.plugin_names_from_type('generator').each do |plugin_name|
        plugin = PDK::PluginManager.instance[plugin_name]
        next if plugin.nil?
        return plugin.generator_klass if plugin.puppet_strings_type == puppet_strings_type
      end
      nil
    end
  end
end
