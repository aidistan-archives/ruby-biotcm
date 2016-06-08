require_relative '../../test_helper'

describe BioTCM::Databases::Medline do
  it 'could search PubMed with specific terms' do
    assert(BioTCM::Databases::Medline.new('IL-2 IBD').count > 0)
  end

  it 'could search PubMed with logical operations' do
    medline = BioTCM::Databases::Medline.new('IL-2 IBD')
    medline.or('IL-2 CRC').and('Cancer')
    assert(medline.count > 0)
  end

  it 'could fetch all related pubmed ids' do
    medline = BioTCM::Databases::Medline.new('IL-2 IBD')
    assert(medline.fetch_pubmed_ids.size > 150)
  end

  it 'could download the query result' do
    filename = __FILE__ + '.tmp'
    BioTCM::Databases::Medline.new('IL-2 IBD CRC').download_abstracts(filename)
    file = File.open(filename)
    assert(!file.readlines.empty?)
    file.close
    File.delete(filename)
  end
end
