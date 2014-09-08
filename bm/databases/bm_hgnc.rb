require_relative '../bm-helper'

hgnc = BioTCM::Databases::HGNC.new
symbols = hgnc.symbol2hgncid.keys

MyBenchmark.group 'HGNC' do |b|
  b.report("Load table") do
    BioTCM::Databases::HGNC.new.as_dictionary
  end

  b.report("Hash way") do
    symbols.collect { |s| hgnc.symbol2hgncid[s] }
  end

  b.report("String way") do
    symbols.collect { |s| s.symbol2hgncid }
  end

  b.report("Array way") do
    symbols.symbol2hgncid
  end
end
