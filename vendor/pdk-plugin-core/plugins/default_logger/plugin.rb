require 'pdk/plugins'

# Setup the autoloaders. Not the greatest, but meh!
module PDK
  module Logger
    autoload :Default, File.expand_path(File.join(__dir__, 'default_logger'))
  end
end

module PDKCorePlugins
  class DefaultLogger < PDK::LoggerPlugin
    def initialize
      super('default_logger')
    end

    def logger_klass
      PDK::Logger::Default
    end
  end
end

PDK::PluginManager.instance.register(PDKCorePlugins::DefaultLogger.new)
