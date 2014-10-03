# Namespace of all scripts
module BioTCM::Apps
  # Built-in-app list
  BUILT_IN = ['gene-detector', 'irb']
  # Built-in apps
  autoload(:App, "biotcm/apps/app")
  autoload(:GeneDetector, "biotcm/apps/gene-detector")
  autoload(:IRB, "biotcm/apps/irb")
end
