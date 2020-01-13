require 'pdk'

module PDKCorePlugins
  class ModuleCLIPlugin < PDK::PluginTypes::CLI
    def initialize
      super('module_cli')
    end

    def create_cri_command
      base_cri_command.define_command do
        name 'module'
        usage _('module [options]')
        summary _('Provide CLI-backwards compatibility to the puppet module tool.')
        description _('This command is only for reminding you how to accomplish tasks with the PDK, when you were previously doing them with the puppet module command.')
        default_subcommand 'help'
      end.tap do |cmd|
        cmd.add_command Cri::Command.new_basic_help
      end
    end
  end
end

PDK::PluginManager.instance.register(PDKCorePlugins::ModuleCLIPlugin.new)
