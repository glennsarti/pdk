require 'pdk'

# Setup the autoloaders. Not the greatest, but meh!
module PDK
  module Validate
    autoload :MetadataJSONLint, File.expand_path(File.join(__dir__, 'metadata_json_lint'))
    autoload :MetadataSyntax, File.expand_path(File.join(__dir__, 'metadata_syntax'))
    autoload :MetadataValidatorGroup, File.expand_path(File.join(__dir__, 'metadata_validator_group'))
  end
end

module PDKCorePlugins
  class MetadataValidatorPlugin < PDK::PluginTypes::Validator
    def initialize
      super('metadata_validator')
    end

    def validator_klass
      PDK::Validate::MetadataValidatorGroup
    end
  end
end

PDK::PluginManager.instance.register(PDKCorePlugins::MetadataValidatorPlugin.new)
