# encoding: UTF-8
require 'benchmark'

unless $:.include?(File.expand_path('../../lib', __FILE__))
  $:.unshift(File.expand_path('../../lib', __FILE__))
end
require 'biotcm'

# Our benchmark DSL 
module MyBenchmark
  def self.group(title=nil, &block)
    if title
      puts ['=== '+ title + ' ===', '']
    end
    Benchmark.bmbm(&block)
    puts
  end
end
