# encoding: UTF-8
require 'benchmark'

unless $:.include?(File.expand_path('../../lib', __FILE__))
  $:.unshift(File.expand_path('../../lib', __FILE__))
end

# Our benchmark DSL 
def benchmark_of(title=nil, &block)
  if title
    puts ['=== '+ title + ' ===', '']
  end
  Benchmark.bmbm(&block)
  puts
end
