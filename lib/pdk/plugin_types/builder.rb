require 'pdk'

module PDK
  module PluginTypes
    class Builder < Plugin
      # @abstract
      # @return [Symbol] The type of builder this is
      def builder_type; end

      def create_instance(_source, _destination, _options); end
    end
  end
end
