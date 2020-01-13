require 'pdk'

module PDK
  module PluginTypes
    class Logger < Plugin
      # @abstract
      # @return [Class] That inherits from ::Logger
      def logger_klass; end
    end
  end
end
