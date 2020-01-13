require 'pdk'

# Setup the autoloaders. Not the greatest, but meh!
module PDK
  module Generate
    autoload :PuppetDefinedTypeGenerator, File.expand_path(File.join(__dir__, 'puppet_defined_type_generator'))
  end
end

module PDKCorePlugins
  class PuppetDefinedTypeGeneratorPlugin < PDK::PluginTypes::Generator
    def initialize
      super('puppet_defined_type_generator')
    end

    def generator_klass
      PDK::Generate::PuppetDefinedTypeGenerator
    end
  end
end

PDK::PluginManager.instance.register(PDKCorePlugins::PuppetDefinedTypeGeneratorPlugin.new)
