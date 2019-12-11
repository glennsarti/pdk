require 'pdk/plugins'

module PDKCorePlugins
  class NewCLIPlugin < PDK::CLIPlugin
    def initialize
      super('new_cli')
    end

    def create_cri_command
      base_cri_command.define_command do
        name 'new'
        usage _('new <thing> [options]')
        summary _('create a new module, etc.')
        description _('Creates a new <thing> using relevant options.')
        default_subcommand 'help'
      end
    end
  end
end

PDK::PluginManager.instance.register(PDKCorePlugins::NewCLIPlugin.new)
