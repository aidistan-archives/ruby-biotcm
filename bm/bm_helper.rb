require 'benchmark'

unless $LOAD_PATH.include?(File.expand_path('../../lib', __FILE__))
  $LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
end
require 'biotcm'

# Suppress log output
BioTCM.logger.level = Logger::FATAL

# Our benchmark DSL
module MyBenchmark
  def self.group(title = nil, &block)
    puts ['=== ' + title + ' ===', ''] if title
    Benchmark.bmbm(&block)
    puts
  end
end
