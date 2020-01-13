require 'pdk'

module PDKCorePlugins
  class ModuleBuildCLIPlugin < PDK::PluginTypes::CLI
    def initialize
      super('module_build_cli')
    end

    def create_cri_command
      PDK::PluginManager.instance[:module_cli].cri_command.define_command do
        name 'build'
        usage _('build')
        summary _('This command is now \'pdk build\'.')

        run do |_opts, _args, _cmd|
          PDK.logger.warn(_("Modules are built using the 'pdk build' command."))
          exit 1
        end
      end
    end
  end
end

PDK::PluginManager.instance.register(PDKCorePlugins::ModuleBuildCLIPlugin.new)
