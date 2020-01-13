require 'pdk'

module PDK
  module PluginTypes
    class UI < Plugin
      # @abstract
      # @return [Class] That inherits from ::Logger
      def ui_klass; end
    end
  end
end
