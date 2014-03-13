# encoding: UTF-8

# Top level namespace of BioTCM
#
# === Initialization
# It's unnecessary to initialize BioTCM after requiring. 
#   require 'biotcm'
#   BioTCM.init # unnecessary but no harm
#
# Sometimes custom initialization fits your need better. Write the process 
# according to {BioTCM.init} to make sure that anything left uninitiated will 
# not affect your final result.
#   require 'biotcm'
#
module BioTCM
  # autoloaders
  autoload(:Modules, "biotcm/modules")
  autoload(:Databases, "biotcm/databases")
  # mannual-loaders
  require 'biotcm/modules/utility'
  
  # Current version of BioTCM
  VERSION = '0.0.0'

  extend Modules::Utility

  # Run BioTCM in irb
  def console
    system "irb -I #{File.dirname(__FILE__)} -r biotcm -r irb/completion --simple-prompt"
  end
  # Default initialization
  # @return [BioTCM]
  def init
    return self
  end
end

# Extention to Ruby's Core library
class String; end
# Extention to Ruby's Core library
class Array; end
