# encoding: UTF-8
require 'json'

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
#   BioTCM.wd = "/home/aidistan/.biotcm"
#
module BioTCM
  # autoloaders
  autoload(:Modules, "biotcm/modules")
  autoload(:Databases, "biotcm/databases")

  extend Modules::Utility
  extend Modules::WorkingDir
  
  # Current version number
  VERSION = '0.0.1'
  # Default working directory
  DEFAULT_WORKING_DIRECTORY = File.expand_path("~/.gem/biotcm")
  # Default url of the meta file
  DEFAULT_META_FILE = 'http://aidistan.github.io/biotcm/meta.json'

  module_function

  # Run BioTCM in console
  def console
    system "irb -I #{File.dirname(__FILE__)} -r biotcm -r irb/completion --simple-prompt"
  end
  # Default initialization
  # @return [BioTCM]
  def init
    BioTCM.wd = BioTCM::DEFAULT_WORKING_DIRECTORY
    return self
  end
  # Get the instance of Logger
  # @return [Logger]
  def log
    Logger.instance(path_to("log/#{get_stamp}.log", true))
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
require 'biotcm/table'
require 'biotcm/logger'
BioTCM.wd = BioTCM::DEFAULT_WORKING_DIRECTORY
