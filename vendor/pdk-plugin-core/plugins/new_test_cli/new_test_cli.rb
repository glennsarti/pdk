require 'pdk/plugins'

module PDKCorePlugins
  class NewTestCLIPlugin < PDK::CLIPlugin
    def initialize
      super('new_test_cli')
    end

    def create_cri_command
      PDK::PluginManager.instance[:new_cli].cri_command.define_command do
        name 'test'
        usage _('test [options] <name>')
        summary _('Create a new test for the object named <name>')
        flag :u, :unit, _('Create a new unit test.')

        PDK::CLI.puppet_version_options(self)
        PDK::CLI.puppet_dev_option(self)

        run do |opts, args, _cmd|
          require 'pdk/util/puppet_strings'
          require 'pdk/util/bundler'

          PDK::CLI::Util.validate_puppet_version_opts(opts)
          PDK::CLI::Util.ensure_in_module!(
            message: _('Tests can only be created from inside a valid module directory.'),
            log_level: :info,
          )

          object_name = args[0]

          if object_name.nil? || object_name.empty?
            PDK.ui.puts command.help
            exit 1
          end

          unless opts[:unit]
            # At a future time, we'll replace this conditional with an interactive
            # question to choose the test type.
            PDK.logger.info _('Test type not specified, assuming unit.')
            opts[:unit] = true
          end

          puppet_env = PDK::CLI::Util.puppet_from_opts_or_env(opts)
          PDK::Util::RubyVersion.use(puppet_env[:ruby_version])
          PDK::Util::Bundler.ensure_bundle!(puppet_env[:gemset])

          mod_root = PDK::Util.module_root
          module_metadata = PDK::Module::Metadata.from_file(File.join(mod_root, 'metadata.json')).data
          module_name = module_metadata['name'].rpartition('-').last

          object_names = [object_name]
          object_names << "#{module_name}::#{object_name}" unless object_name.start_with?("#{module_name}::")

          string_types =  PDK::Util::PuppetStrings.puppet_string_types_for_object_names(object_names)
          if string_types.empty?
            raise PDK::CLI::ExitWithError, _('Unable to find anything called "%{object}" to generate unit tests for.') % {
              object: object_name
            }
          end
          PDK.logger.debug _("Found the object types '%{object_types}' for the name '%{name}'") % { object_types: string_types.join('\', \''), name: object_name }

          klass = string_types.map { |string_type| PDK::Generate.generator_for_puppet_strings_type(string_type) }
                              .find { |gen_klass| !gen_klass.nil? }
          raise PDK::CLI::ExitWithError, _('PDK does not support generating unit tests for "%{object_types}" objects.') % { object_types: string_types.join(', ') } if klass.nil?

          gen = klass.new(object_name, mod_root, opts.merge(spec_only: true))
          PDK.logger.debug(_('Using the %{name} generator') % { name: gen.object_type })
          updates = gen.generate_to_disk
          PDK.logger.info("There was nothing to generate") unless updates.changes?
        end
      end
    end
  end
end

PDK::PluginManager.instance.register(PDKCorePlugins::NewTestCLIPlugin.new)
