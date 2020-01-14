require 'pdk'

module PDKCorePlugins
  class TestPatternCLIPlugin < PDK::PluginTypes::CLI
    def initialize
      super('testpattern_cli')
    end

    def create_cri_command
      base_cri_command.define_command do
        name 'testpattern'
        usage _('testpattern')
        summary _('Outputs a bunch of stuff to test the UI')

        flag nil, :ui_jobs, _('Run ui jobs.')
        flag nil, :parallel, _('Run testpattern in parallel.')

        run do |opts, args, _cmd|
          PDK.logger.unknown _('Unknown level log message')
          PDK.logger.fatal _('Fatal level log message')
          PDK.logger.error _('Error level log message')
          PDK.logger.warn _('Warn level log message')
          PDK.logger.info _('Info level log message')
          PDK.logger.debug _('Debug level log message')

          exit 0 unless opts[:ui_jobs]

          options = {}
          require_relative File.join(__dir__, 'bogus_validators')
          validators = [
            PDK::Validate::BogusValidatorGroup1,
            PDK::Validate::BogusValidatorGroup2,
            PDK::Validate::BogusValidatorGroup3,
            PDK::Validate::BogusValidatorGroup4,
            PDK::Validate::BogusValidatorGroup5,
          ]
          exit_code, report = PDK::Validate.invoke_validators(validators, opts[:parallel], options)

          # report_formats.each do |format|
          #   report.send(format[:method], format[:target])
          # end

          exit (exit_code.nil? ? -1 : exit_code)
        end
      end
    end
  end
end

PDK::PluginManager.instance.register(PDKCorePlugins::TestPatternCLIPlugin.new)
