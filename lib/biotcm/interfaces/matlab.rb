module BioTCM
  module Interfaces

    # Interface to MATLAB
    module Matlab

      include Interface

      # Run MATLAB script
      def run_matlab_script(script_path, matlab_path: 'matlab')
        system("#{matlab_path} #{script_path}")
      end

      # Evaluate MATLAB script
      # @see Interface#render_template
      def evaluate_matlab_script(template_path, context = nil, matlab_path: 'matlab')
        raise ArgumentError unless /\.m\.erb$/i =~ template_path
        run_matlab_script(render_template(template_path, context).path, matlab_path: matlab_path)
      end

    end
  end
end
