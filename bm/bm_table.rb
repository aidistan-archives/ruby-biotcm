# encoding: UTF-8
require_relative 'bm-helper'
require 'biotcm/table'

Benchmark.bmbm do |b|
  b.report("BioTCM::Table#new") do
    @tab1 = BioTCM::Table.new("table_1.txt")
    @tab2 = BioTCM::Table.new("table_2.txt")
  end

  b.report("BioTCM::Table#merge") do
    @tab1.merge(@tab2)
  end
end
