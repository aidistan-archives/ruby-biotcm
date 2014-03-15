# encoding: UTF-8
require_relative 'bm-helper'
require 'biotcm/table'

Benchmark.bmbm do |b|
  b.report("Table#new") do
    @tab1 = BioTCM::Table.new("table_1.txt")
    @tab2 = BioTCM::Table.new("table_2.txt")
  end

  b.report("Table#merge") do
    @tab = @tab1.merge(@tab2)
  end

  b.report("Table#select") do
    @tab.select_col(['Name', 'Fullname'])
  end
end
