require 'pdk/plugins'

# Setup the autoloaders. Not the greatest, but meh!
module PDK
  module Generate
    autoload :BoltTaskGenerator, File.expand_path(File.join(__dir__, 'bolt_task_generator'))
  end
end

module PDKCorePlugins
  class BoltTaskGeneratorPlugin < PDK::GeneratorPlugin
    def initialize
      super('bolt_task_generator')
    end

    def generator_klass
      PDK::Generate::BoltTaskGenerator
    end
  end
end

PDK::PluginManager.instance.register(PDKCorePlugins::BoltTaskGeneratorPlugin.new)
