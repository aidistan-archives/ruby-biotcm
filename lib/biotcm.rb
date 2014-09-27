require 'json'

# Top level namespace of BioTCM
#
# = Initialization
# {BioTCM.init} is called automatically when {BioTCM} is required.
#   # in biotcm.rb
#   module BioTCM
#     # ...
#   end
#   BioTCM.init
#
# Sometimes custom initialization fits your need better. Override configs 
# according to {BioTCM.init}, right immediately after you require {BioTCM}, 
# to make sure that nothing will not affect your final result.
#   require 'biotcm'
#   BioTCM.wd = "/home/aidistan/.biotcm"
#
module BioTCM
  # autoloaders
  autoload(:Modules, "biotcm/modules")
  autoload(:Databases, "biotcm/databases")
  autoload(:Scripts, "biotcm/scripts")

  extend Modules::Utility
  extend Modules::WorkingDir
  
  # Current version number
  VERSION = '0.0.7'
  # Default working directory
  DEFAULT_WORKING_DIRECTORY = File.expand_path("~/.gem/biotcm")
  # Default url of the meta file
  DEFAULT_META_FILE = 'http://biotcm.github.io/biotcm/meta.json'

  module_function

  # Run BioTCM in console
  def console
    system "irb -I #{File.dirname(__FILE__)} -r biotcm -r irb/completion --simple-prompt"
  end
  # Default initialization
  # @return [nil]
  def init
    require 'biotcm/logger'
    require 'biotcm/table'
    require 'biotcm/network'
    BioTCM.wd = BioTCM::DEFAULT_WORKING_DIRECTORY
    return nil
  end
  # Get the instance of Logger
  # @return [Logger]
  def logger
    Logger.instance(path_to("log/#{get(:stamp)}.log", secure:true))
  end
  # Get meta value
  def get_meta(key)
    return @meta[key] if @meta
    @meta = JSON.parse(get(DEFAULT_META_FILE))
    @meta[key]
  end
end

# Extention to Ruby's Core library
class String; end
# Extention to Ruby's Core library
class Array; end

# Necessary initialization
BioTCM.init
