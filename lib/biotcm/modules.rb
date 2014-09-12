# Namespace of all modules
#
# Modules in BioTCM are independent from the gem, which makes them able
# to be included anywhere.
module BioTCM::Modules
  autoload(:Utility, 'biotcm/modules/utility')
  autoload(:WorkingDir, 'biotcm/modules/workingdir')
end
