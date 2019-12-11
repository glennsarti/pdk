require 'pdk'

module PDK
  module Generate
    class Generator
      attr_reader :object_name

      attr_reader :root_path

      attr_reader :options

      def initialize(object_name = nil, root_path = nil, options = nil)
        @object_name = nil
        @root_path = nil
        @options = {}

        @object_name = object_name unless object_name.nil?
        @root_path = root_path unless root_path.nil?
        @options = options unless options.nil?
      end

      # Retrieves the type of the object being generated, e.g. :class,
      # :defined_type, etc. This is specified in the subclass
      #
      # @return [Symbol] the type of the object being generated.
      #
      # @abstract
      # @api private
      def object_type
        raise NotImplementedError
      end

      # Retrieves the type of the object being generated as represented in
      # the JSON output of puppet-strings.
      #
      # @return [String] the type of the object being generated or nil if
      #   there is no mapping.
      #
      # @abstract
      # @api private
      def puppet_strings_type
        nil
      end

      # TODO: Crappy method name but 🤷‍♂️, don't know a better one yet.
      def validation_errors
        []
      end

      # TODO: Crappy method name but 🤷‍♂️, don't know a better one yet.
      def valid?
        validation_errors.empty?
      end

      # Returns a list of files (created from root_path) that would be modified
      # from this generator
      #
      # @param force Force the generation to occur even if there are validation errors
      #
      # @return [PDK::FileUpdateManager] A Manager class which can be used to inspect and/or apply the file updates
      #
      # @abstract
      # @api public
      def generate(force = false)
        validation_errors.each do |err_msg|
          text = "Unable to generate #{object_type}: #{err_msg}"
          if force
            PDK.logger.warn(text)
          else
            raise PDK::CLI::ExitWithError, text
          end
        end

        PDK::FileUpdateManager.new
      end

      # Applies and returns a list of files (created from root_path) that would be created
      # from this generator
      #
      # @param force Force the generation to occur even if there are validation errors
      #
      # @return [PDK::FileUpdateManager] A Manager class which can be used to inspect the files updated
      def generate_to_disk(force = false)
        updates = generate(force)

        updates.files_to_write.each do |dest_path|
          # Check if the file already exists
          next unless PDK::Util::Filesystem.exist?(dest_path)

          if force
            PDK.logger.warn(_("'%{file}' will be overwritten while generating %{object_type}.") % {
              file:        dest_path,
              object_type: object_type
            })
          else
            raise PDK::CLI::ExitWithError, _("Unable to generate %{object_type}; '%{file}' already exists.") % {
              file:        dest_path,
              object_type: object_type,
            }
          end
        end

        # Write it to disk
        updates.sync_changes!

        updates
      end
    end
  end
end
