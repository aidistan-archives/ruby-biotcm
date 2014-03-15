# encoding: UTF-8
require 'test/unit'
require 'shoulda-context'

unless $:.include?(File.expand_path('../../lib', __FILE__))
  $:.unshift(File.expand_path('../../lib', __FILE__))
end
require 'biotcm'

# Suppress output from screen_logger
BioTCM.log.screen_logger.level = Logger::UNKNOWN
