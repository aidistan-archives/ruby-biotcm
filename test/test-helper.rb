require 'minitest/autorun'
require "minitest/reporters"
Minitest::Reporters.use!

unless $:.include?(File.expand_path('../../lib', __FILE__))
  $:.unshift(File.expand_path('../../lib', __FILE__))
end
require 'biotcm'

# Suppress output from screen_logger
BioTCM.logger.screen_logger.level = Logger::UNKNOWN
