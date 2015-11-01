require 'tempfile'
require 'erb'

# Common methods for interfaces
module BioTCM::Interfaces::Interface
  # Render the template
  # @param template_path [String]
  # @param context [Binding, Hash]
  # @return [Tempfile] a tempfile containing rendered script
  def render_template(template_path, context)
    # Check extension
    fail ArgumentError unless /\.erb$/i =~ template_path

    # Prepare
    template = ERB.new(File.read(template_path))
    filename = File.basename(template_path).sub('.', '[.].').sub(/\.erb$/, '')
    filename = filename.split('.', 2)
    context = OpenStruct.new(context).instance_eval { binding } unless context.is_a?(Binding)

    # Render
    script = Tempfile.new(filename)
    script.write(template.result(context))
    script.rewind
    script
  end
end
