require 'pdk'

module PDKCorePlugins
  class BuildModuleCLIPlugin < PDK::PluginTypes::CLI
    def initialize
      super('build_module_cli')
    end

    def create_cri_command
      PDK::PluginManager.instance[:build_cli].cri_command.define_command do
        name 'module'
        usage _('build module [options]')
        summary _('Builds a package from the module that can be published to the Puppet Forge.')

        option nil, 'target-dir',
              _('The target directory where you want PDK to write the package.'),
              argument: :required

        option nil, 'force', _('Skips the prompts and builds the module package.')

        run do |opts, _args, _cmd|
          # Make sure build is being run in a valid module directory with a metadata.json
          PDK::CLI::Util.ensure_in_module!(
            message:   _('`pdk build module` can only be run from inside a valid module with a metadata.json.'),
            log_level: :info,
          )

          PDK::CLI::Util.analytics_screen_view('build', opts)

          module_root = PDK::Util.module_root
          metadata_file = File.join(module_root, 'metadata.json')
          module_metadata = PDK::Module::Metadata.from_file(metadata_file)

          # TODO: Ensure forge metadata has been set, or call out to interview
          #       to set it.
          unless module_metadata.forge_ready?
            if opts[:force]
              PDK.logger.warn _(
                'This module is missing the following fields in the metadata.json: %{fields}. ' \
                'These missing fields may affect the visibility of the module on the Forge.',
              ) % {
                fields: module_metadata.missing_fields.join(', '),
              }
            else
raise "module_metadata.interview_for_forge!  is BROKEN!!!!!"
              module_metadata.interview_for_forge!
              module_metadata.write!(metadata_file)
            end
          end

          builder = PDK::Build.create_builder(:module, module_root, opts[:'target-dir'], opts)
          raise PDK::CLI::ExitWithError, _('Could not find the module builder. Are you missing a plugin?') if builder.nil?
          raise PDK::CLI::ExitWithError, _('Unexpected module builder of %{class}. Are you missing a plugin?') % { class: builder.class.name} unless builder.is_a?(::PuppetModuleBuilder::Builder)

          unless opts[:force]
            if builder.package_already_exists?
              PDK.logger.info _("The file '%{package}' already exists.") % { package: builder.package_file }

              unless PDK::CLI::Util.prompt_for_yes(_('Overwrite?'), default: false)
                PDK.logger.info _('Build cancelled; exiting.')
                exit 0
              end
            end

            unless builder.module_pdk_compatible?
              PDK.logger.info _('This module is not compatible with PDK, so PDK can not validate or test this build. ' \
                                'Unvalidated modules may have errors when uploading to the Forge. ' \
                                'To make this module PDK compatible and use validate features, cancel the build and run `pdk convert`.')

              unless PDK::CLI::Util.prompt_for_yes(_('Continue build without converting?'))
                PDK.logger.info _('Build cancelled; exiting.')
                exit 0
              end
            end
          end

          PDK.logger.info _('Building %{module_name} version %{module_version}') % {
            module_name:    module_metadata.data['name'],
            module_version: module_metadata.data['version'],
          }

          builder.build

          PDK.logger.info _('Build of %{package_name} has completed successfully. Built package can be found here: %{package_path}') % {
            package_name: module_metadata.data['name'],
            package_path: builder.package_file,
          }
        end
      end
    end
  end
end

PDK::PluginManager.instance.register(PDKCorePlugins::BuildModuleCLIPlugin.new)
