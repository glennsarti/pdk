require 'pdk'

module PDK
  module Generate
    class PuppetDefinedTypeGenerator < PuppetModuleThingGenerator
      def object_type
        :defined_type
      end

      def puppet_strings_type
        'defined_types'.freeze
      end

      def template_data
        { name: actual_object_name }
      end

      def template_files
        class_name_parts = actual_object_name.split('::')[1..-1]
        class_name_parts << 'init' if class_name_parts.empty?
        manifest_dest_path = File.join(root_path, 'manifests', *class_name_parts) + '.pp'
        spec_dest_path     = File.join(root_path, 'spec', 'defines', *class_name_parts) + '_spec.rb'

        {
          manifest_dest_path => PDK::TemplateFile.new(File.join(__dir__, 'defined_type.erb'), template_data),
          spec_dest_path     => PDK::TemplateFile.new(File.join(__dir__, 'defined_type_spec.erb'), template_data)
        }
      end

      def actual_object_name
        mod_name = module_name
        object_name_parts = object_name.split('::')
        # If the new class name doesn't start with the module's name, prefix it.
        if object_name_parts.first == mod_name
          object_name
        else
          [mod_name, object_name].join('::')
        end
      end
    end
  end
end