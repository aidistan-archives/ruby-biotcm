# Namespace of all interfaces. Generally, there are two ways to call:
#
# - Run: directly run the script
# - Evaluate: render the template to get a complete script, then run it
#
module BioTCM::Interfaces
  autoload(:Interface, 'biotcm/interfaces/interface')
  autoload(:Matlab, 'biotcm/interfaces/matlab')
  autoload(:R, 'biotcm/interfaces/r')
end
