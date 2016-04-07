require 'json'
require 'logger'

# Top level namespace of BioTCM
module BioTCM
  autoload(:Apps, 'biotcm/apps')
  autoload(:Databases, 'biotcm/databases')
  autoload(:Interfaces, 'biotcm/interfaces')
  autoload(:Utility, 'biotcm/utility')
  autoload(:VERSION, 'biotcm/version')

  extend Utility

  # Default working directory
  DEFAULT_WORKING_DIRECTORY = File.expand_path('~/.gem/biotcm')
  # Default url of the meta file
  DEFAULT_META_FILE_URL = 'http://biotcm.github.io/meta/meta.json'

  module_function

  # Get the instance of Logger
  # @return [Logger]
  def logger
    @logger ||= Logger.new(STDOUT)
  end

  # Get meta value
  def meta
    @meta ||= JSON.parse(curl(DEFAULT_META_FILE_URL))
  end
end

# Extention to Ruby's Core library
class String; end
# Extention to Ruby's Core library
class Array; end

# Require all necessary classes
require 'biotcm/layer'
require 'biotcm/table'
