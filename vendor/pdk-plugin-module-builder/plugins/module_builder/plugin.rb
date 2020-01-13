require 'pdk'

module PDKCorePlugins
  class ModuleBuilderPlugin < PDK::PluginTypes::Builder
    def initialize
      super('module_builder')
    end

    def builder_type
      :module
    end

    def create_instance(source, destination, options = {})
     source = source.nil? ? PDK::Util.module_root : source

      require 'puppet_module_builder'
      builder =  PuppetModuleBuilder::Builder.new(source, destination, PDK.logger, options)
    end
  end
end

PDK::PluginManager.instance.register(PDKCorePlugins::ModuleBuilderPlugin.new)
