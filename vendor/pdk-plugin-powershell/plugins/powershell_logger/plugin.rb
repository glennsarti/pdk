require 'pdk'

# Setup the autoloaders. Not the greatest, but meh!
module PDK
  module Logger
    autoload :PowerShell, File.expand_path(File.join(__dir__, 'powershell_logger'))
  end
end

module PDKCorePlugins
  class PowerShellLogger < PDK::PluginTypes::Logger
    def initialize
      super('powershell_logger')
    end

    def logger_klass
      PDK::Logger::PowerShell
    end
  end
end

PDK::PluginManager.instance.register(PDKCorePlugins::PowerShellLogger.new)
