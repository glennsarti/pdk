require 'pdk/plugins'

# Setup the autoloaders. Not the greatest, but meh!
module PDK
  module Validate
    autoload :PuppetEPP, File.expand_path(File.join(__dir__, 'puppet_epp'))
    autoload :PuppetLint, File.expand_path(File.join(__dir__, 'puppet_lint'))
    autoload :PuppetSyntax, File.expand_path(File.join(__dir__, 'puppet_syntax'))
    autoload :PuppetValidatorGroup, File.expand_path(File.join(__dir__, 'puppet_validator_group'))
  end
end

module PDKCorePlugins
  class PuppetValidatorPlugin < PDK::ValidatorPlugin
    def initialize
      super('puppet_validator')
    end

    def validator_klass
      PDK::Validate::PuppetValidatorGroup
    end
  end
end

PDK::PluginManager.instance.register(PDKCorePlugins::PuppetValidatorPlugin.new)
