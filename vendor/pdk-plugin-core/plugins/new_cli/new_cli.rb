require 'pdk'

module PDKCorePlugins
  class NewCLIPlugin < PDK::PluginTypes::CLI
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
      end.tap do |cmd|
        cmd.add_command Cri::Command.new_basic_help
      end
    end
  end
end

PDK::PluginManager.instance.register(PDKCorePlugins::NewCLIPlugin.new)
