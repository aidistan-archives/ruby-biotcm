require_relative '../../test_helper'

describe BioTCM::Databases::KEGG do
  it 'must raise error if given pathway not exists' do
    assert_raises(RuntimeError) { BioTCM::Databases::KEGG.get_pathway('00000') }
  end

  it 'must download KGMLs' do
    filename = BioTCM.path_to('kegg/hsa05010.xml')
    File.delete(filename) if FileTest.exist?(filename)
    BioTCM::Databases::KEGG.get_pathway('05010')
    assert(FileTest.exist?(filename))
  end

  it 'must load KGMLs and create Pathway objects' do
    kegg = BioTCM::Databases::KEGG.new('05010')
    assert(kegg.pathways['hsa05010'])
  end

  it 'have more pathways if extended (in most cases)' do
    kegg = BioTCM::Databases::KEGG.new('05010')
    before = kegg.pathways.size
    kegg.extend_to_associated
    assert(kegg.pathways.size > before)
  end
end
