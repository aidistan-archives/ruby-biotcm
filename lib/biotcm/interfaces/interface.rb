require 'tempfile'
require 'erb'

# Common methods for interfaces
module BioTCM::Interfaces::Interface

  # Render the template
  # @param template_path [String]
  # @param context [Binding, Hash]
  # @return [Tempfile] a tempfile containing rendered script
  def render_template(template_path, context = nil)
    script = Tempfile.new('script')
    template = ERB.new(File.read(template_path))
    script.write(template.result(context.is_a?(Binding) ? context :
      OpenStruct.new(context).instance_eval { binding }))
    script.rewind
    return script
  end

end
