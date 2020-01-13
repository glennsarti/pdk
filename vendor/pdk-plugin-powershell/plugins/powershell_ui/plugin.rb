require 'pdk'

# Setup the autoloaders. Not the greatest, but meh!
module PDK
  module UI
    autoload :Powershell, File.expand_path(File.join(__dir__, 'powershell_ui'))
  end
end

module PDKCorePlugins
  class PowershellUI < PDK::PluginTypes::UI
    def initialize
      super('powershell_ui')
    end

    def ui_klass
      PDK::UI::Powershell
    end
  end
end

PDK::PluginManager.instance.register(PDKCorePlugins::PowershellUI.new)
