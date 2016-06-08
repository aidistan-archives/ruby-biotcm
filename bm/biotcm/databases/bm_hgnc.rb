require_relative '../../bm_helper'

hgnc = BioTCM::Databases::HGNC

MyBenchmark.group 'HGNC' do |b|
  b.report('Load table') do
    BioTCM::Databases::HGNC.load.as_dictionary
  end

  b.report('Hash way') do
    symbols = hgnc.symbol2hgncid.keys
    symbols.collect { |s| hgnc.symbol2hgncid[s] }
  end

  b.report('String way') do
    symbols = hgnc.symbol2hgncid.keys
    symbols.collect(&:symbol2hgncid)
  end

  b.report('Array way') do
    symbols = hgnc.symbol2hgncid.keys
    symbols.symbol2hgncid
  end
end
