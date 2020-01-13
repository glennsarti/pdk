require 'pdk'

module PDKCorePlugins
  class ReleasePublishCLIPlugin < PDK::PluginTypes::CLI
    def initialize
      super(:release_publish_cli)
    end

    def create_cri_command
      PDK::PluginManager.instance[:release_cli].cri_command.define_command do
        name 'publish'
        usage _('publish [options] <tarball>')
        summary _('(Experimental) Publishes the module <tarball> to the Forge.')

        flag nil, :force,                _('Publish the module automatically, with no prompts.')

        option nil, :'forge-upload-url', _('Set forge upload url path.'),
              argument: :required, default: 'https://forgeapi.puppetlabs.com/v3/releases'

        option nil, :'forge-token', _('Set Forge API token.'), argument: :required, default: nil

        run do |opts, _args, cmd|
          # Make sure build is being run in a valid module directory with a metadata.json
          PDK::CLI::Util.ensure_in_module!(
            message:   _("`pdk release #{cmd.name}` can only be run from inside a valid module with a metadata.json."),
            log_level: :info,
          )

          opts[:'skip-validation'] = true
          opts[:'skip-changelog'] = true
          opts[:'skip-dependency'] = true
          opts[:'skip-documentation'] = true
          opts[:'skip-build'] = true
          opts[:'skip-versionset'] = true
          opts[:force] = true unless PDK::CLI::Util.interactive?

          PDKCorePlugins::ReleaseCLIPlugin.prepare_publish_interview(TTY::Prompt.new(help_color: :cyan), opts) unless opts[:force]

          PDKCorePlugins::ReleaseCLIPlugin.send_analytics("release #{cmd.name}", opts)

          release = PDK::Module::Release.new(nil, opts)

          release.run
        end
      end
    end
  end
end

PDK::PluginManager.instance.register(PDKCorePlugins::ReleasePublishCLIPlugin.new)
