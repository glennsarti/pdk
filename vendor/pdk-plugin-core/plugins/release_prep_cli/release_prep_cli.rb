require 'pdk'

module PDKCorePlugins
  class ReleasePrepCLIPlugin < PDK::PluginTypes::CLI
    def initialize
      super('release_prep_cli')
    end

    def create_cri_command
      PDK::PluginManager.instance[:release_cli].cri_command.define_command do
        name 'prep'
        usage _('prep [options]')
        summary _('(Experimental) Performs all the pre-release checks to ensure module is ready to be released')

        flag nil, :force,                _('Prepare the module automatically, with no prompts.')
        flag nil, :'skip-validation',    _('Skips the module validation check.')
        flag nil, :'skip-changelog',     _('Skips the automatic changelog generation.')
        flag nil, :'skip-dependency',    _('Skips the module dependency check.')
        flag nil, :'skip-documentation', _('Skips the documentation update.')

        option nil, :version, _('Update the module to the specified version prior to release. When not specified, the new version will be computed from the Changelog where possible.'),
               argument: :required

        run do |opts, _args, cmd|
          # Make sure build is being run in a valid module directory with a metadata.json
          #PDK::CLI::Util.ensure_in_module!(
          #  message:   _("`pdk release #{cmd.name}` can only be run from inside a valid module with a metadata.json."),
          #  log_level: :info,
          #)

          opts[:'skip-build'] = true
          opts[:'skip-publish'] = true

          PDKCorePlugins::ReleaseCLIPlugin.prepare_interview(opts) unless opts[:force]

          PDKCorePlugins::ReleaseCLIPlugin.send_analytics("release #{cmd.name}", opts)

          release = PDK::Module::Release.new(nil, opts)

          PDKCorePlugins::ReleaseCLIPlugin.module_compatibility_checks!(release, opts)

          release.run
        end
      end
    end
  end
end

PDK::PluginManager.instance.register(PDKCorePlugins::ReleasePrepCLIPlugin.new)
