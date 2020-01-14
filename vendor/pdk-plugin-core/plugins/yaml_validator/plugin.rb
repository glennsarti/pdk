require 'pdk'

# Setup the autoloaders. Not the greatest, but meh!
module PDK
  module Validate
    autoload :YAMLSyntax, File.expand_path(File.join(__dir__, 'yaml_syntax'))
    autoload :YAMLValidatorGroup, File.expand_path(File.join(__dir__, 'yaml_validator_group'))
  end
end

module PDKCorePlugins
  class YamlValidatorPlugin < PDK::PluginTypes::Validator
    def initialize
      super('yaml_validator')
    end

    def validator_klass
      PDK::Validate::YAMLValidatorGroup
    end
  end
end

PDK::PluginManager.instance.register(PDKCorePlugins::YamlValidatorPlugin.new)
