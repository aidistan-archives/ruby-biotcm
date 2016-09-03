require_relative '../../test_helper'

describe BioTCM::Databases::KEGG do
  it 'should get pathway lists' do
    list = BioTCM::Databases::KEGG.get_pathway_list('hsa')
    assert_instance_of(Array, list)
    refute_empty(list)
  end

  it 'should raise error if pathway not exists' do
    assert_raises(RuntimeError) do
      BioTCM::Databases::KEGG.get_pathway('00000')
    end
  end

  it 'should download and parse KGMLs' do
    filename = BioTCM.path_to('kegg/hsa05010.xml')
    File.delete(filename) if FileTest.exist?(filename)

    pathway = BioTCM::Databases::KEGG.get_pathway('05010')
    assert(FileTest.exist?(filename))
    assert_instance_of(Hash, pathway)
  end
end
