require 'pdk'

module PDK
  module PluginTypes
    class CLI < Plugin
      attr_reader :cri_command

      def initialize(name)
        super(name)
        @cri_command = nil
      end

      def activate!
        return if activated?
        @cri_command = create_cri_command
        super()
      end

      # @abstract
      def create_cri_command
        raise "create_cri_command must be implemented in #{self.class}"
      end

      private

      def base_cri_command
        # TODO: This is a bit ugly for now
        PDK::CLI.instance_variable_get(:@base_cmd)
      end
    end
  end
end
