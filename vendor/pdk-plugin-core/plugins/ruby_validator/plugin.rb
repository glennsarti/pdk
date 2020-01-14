require 'pdk'

# Setup the autoloaders. Not the greatest, but meh!
module PDK
  module Validate
    autoload :RubyRubocop, File.expand_path(File.join(__dir__, 'ruby_rubocop'))
    autoload :RubyValidatorGroup, File.expand_path(File.join(__dir__, 'ruby_validator_group'))
  end
end

module PDKCorePlugins
  class RubyValidatorPlugin < PDK::PluginTypes::Validator
    def initialize
      super('ruby_validator')
    end

    def validator_klass
      PDK::Validate::RubyValidatorGroup
    end
  end
end

PDK::PluginManager.instance.register(PDKCorePlugins::RubyValidatorPlugin.new)
