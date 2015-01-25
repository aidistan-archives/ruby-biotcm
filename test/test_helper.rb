require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!
require 'coveralls'
Coveralls.wear!

unless $LOAD_PATH.include?(File.expand_path('../../lib', __FILE__))
  $LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
end
require 'biotcm'

# Suppress output from screen_logger
BioTCM.logger.screen_logger.level = Logger::UNKNOWN
