require 'fileutils'
require 'logger'
require 'net/http'
require 'yaml'

# Top level namespace of BioTCM
module BioTCM
  autoload(:Apps, 'biotcm/apps')
  autoload(:Databases, 'biotcm/databases')
  autoload(:Interfaces, 'biotcm/interfaces')
  autoload(:VERSION, 'biotcm/version')

  # Default data directory
  DEFAULT_DATA_DIRECTORY = File.expand_path('~/.gem/biotcm')
  # Default url of the meta file
  DEFAULT_META_FILE_URL = 'http://aidistan.github.io/ruby-biotcm/meta.yaml'.freeze

  module_function

  # Get an url
  # @param url [String]
  # @return [String] the responce body
  # @raise RuntimeError if return status is not 200
  def curl(url, params: nil)
    url += '?' + params.reject { |_, v| v.nil? }.map { |k, v| k.to_s + '=' + v.to_s }.join('&') if params

    res = Net::HTTP.get_response(URI(url))

    if res.is_a?(Net::HTTPOK)
      res.body
    else
      raise "HTTP status #{res.code} returned when trying to get #{url.inspect}"
    end
  end

  # Get the logger
  # @return [Logger]
  def logger
    @logger ||= Logger.new(STDOUT)
  end

  # Get meta values
  # @return [Hash]
  def meta
    @meta ||= YAML.load(curl(DEFAULT_META_FILE_URL))
  end

  # Make a path for data
  # @param relative_path [String]
  # @return [String]
  def path_to(relative_path, mkdir_p: true)
    File.expand_path(relative_path, DEFAULT_DATA_DIRECTORY)
      .tap { |path| FileUtils.mkdir_p(File.dirname(path)) if mkdir_p }
  end

  # Get a stamp string containing time and thread_id
  # @return [String]
  # @example
  #   BioTCM::Utility.stamp # => "20140314_011353_1bbfd18"
  def stamp
    Time.now.to_s.split(' ')[0..1]
      .push((Thread.current.object_id << 1).to_s(16))
      .join('_').gsub(/-|:/, '')
  end
end

# Require all necessary classes
require 'biotcm/layer'
require 'biotcm/table'
