require 'pdk'

module PDK
  module Validate
    autoload :Validator, 'pdk/validate/validator'
    autoload :ExternalCommandValidator, 'pdk/validate/external_command_validator'
    autoload :InternalRubyValidator, 'pdk/validate/internal_ruby_validator'
    autoload :ValidatorGroup, 'pdk/validate/validator_group'

    def self.validators
      return @validators.dup unless @validators.nil?
      # Any core/inbuilt validators go here
      @validators = []

      PDK::PluginManager.instance.activate_plugin_type!('validator')
      PDK::PluginManager.instance.plugin_names_from_type('validator').each do |plugin_name|
        plugin = PDK::PluginManager.instance[plugin_name]
        next if plugin.nil?
        @validators << plugin.validator_klass
      end

      @validators.dup
    end

    def self.invoke_validators(validators, parallel = false, options = {})
      require 'pdk/cli/exec_group'
      exec_group = PDK::CLI::ExecGroup.create(
        _('Validating module using %{num_of_threads} threads' % { num_of_threads: validators.count }),
        { parallel: parallel },
        options
      )

      instances = validators.map { |klass| klass.new(options) }
      instances.each { |instance| instance.prepare_invoke! }

      report = PDK::Report.new
      instances.each do |validator|
        exec_group.register do
          validator.invoke(report)
        end
      end

      return [exec_group.exit_code, report]
    end

    class ParseOutputError < StandardError; end
  end
end
