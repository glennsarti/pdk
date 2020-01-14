require 'pdk'

module PDKCorePlugins
  class BuildCLIPlugin < PDK::PluginTypes::CLI
    def initialize
      super('build_cli')
    end

    def create_cri_command
      base_cri_command.define_command do

        name 'build'
        usage _('build <thing> [options]')
        summary _('Builds a new <thing> using the relevant options.')
        default_subcommand 'module' # This is for backwards compatibility. And will only work if the module builder plugin is present

        # Default options for any builder
        option nil, 'target-dir',
               _('The target directory where you want PDK to write the package.'),
               argument: :required, default: File.join(Dir.pwd, 'pkg')

        option nil, 'force', _('Skips the prompts and builds the package.')

      end.tap do |cmd|
        cmd.add_command Cri::Command.new_basic_help
      end
    end
  end
end

PDK::PluginManager.instance.register(PDKCorePlugins::BuildCLIPlugin.new)
