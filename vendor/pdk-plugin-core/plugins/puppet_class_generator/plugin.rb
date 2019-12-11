require 'pdk/plugins'


# Setup the autoloaders. Not the greatest, but meh!
module PDK
  module Generate
    autoload :PuppetClassGenerator, File.expand_path(File.join(__dir__, 'puppet_class_generator'))
  end
end

module PDKCorePlugins
  class PuppetClassGeneratorPlugin < PDK::GeneratorPlugin
    def initialize
      super('puppet_class_generator')
    end

    def generator_klass
      PDK::Generate::PuppetClassGenerator
    end
  end
end

PDK::PluginManager.instance.register(PDKCorePlugins::PuppetClassGeneratorPlugin.new)
