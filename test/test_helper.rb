require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!

unless $LOAD_PATH.include?(File.expand_path('../../lib', __FILE__))
  $LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
end
require 'biotcm'
