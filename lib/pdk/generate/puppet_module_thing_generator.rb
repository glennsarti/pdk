require 'pdk'

module PDK
  module Generate
    class PuppetModuleThingGenerator < Generator
      def generate(*_)
        updates = super

        only_spec_files = options[:spec_only] || false
        spec_path = File.join(root_path, 'spec', '/')

        template_files.each do |destination, source|
          next unless !only_spec_files || destination.start_with?(spec_path)
          case source
          when PDK::TemplateFile
            updates.create_update(destination, source.render)
          when String
            updates.create_update(destination, source)
          else
            # Shouldn't happen!
            raise "Unknown template file type #{source.class}"
          end
        end

        #updates.noop = true

        updates
      end

      # @return [Hash{String => String,PDK::TemplateFile}] Source template file and destination file
      #
      # @abstract
      # @api private
      def template_files
        []
      end

      # @return [Hash{String => String}] Source template file and destination file
      # @abstract
      # @api private
      def template_data
        {}
      end

      # Some generators need to munge the object name when generating files
      # Override this method to return the actual object name
      #
      # @return [String] The actual object name
      #
      # @api private
      def actual_object_name
        object_name
      end

      private

      # Retrieves the name of the module (without the forge username) from the
      # module metadata.
      #
      # @param module_root [String] The root of the puppet module.  Assumes it is valid and has a valid metadata.json
      #
      # @return [String] The name of the module.
      #
      # @api private
      def module_name
        return @module_name unless @module_name.nil?
        metadata = PDK::Module::Metadata.from_file(File.join(root_path, 'metadata.json')).data
        @module_name = metadata['name'].rpartition('-').last
      rescue ArgumentError => e
        raise PDK::CLI::FatalError, e
      end
    end
  end
end
