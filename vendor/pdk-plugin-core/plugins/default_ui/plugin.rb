require 'pdk/plugins'

# Setup the autoloaders. Not the greatest, but meh!
module PDK
  module UI
    autoload :Default, File.expand_path(File.join(__dir__, 'default_ui'))
  end
end

module PDKCorePlugins
  class DefaultUI < PDK::UIPlugin
    def initialize
      super('default_ui')
    end

    def ui_klass
      PDK::UI::Default
    end
  end
end

PDK::PluginManager.instance.register(PDKCorePlugins::DefaultUI.new)
