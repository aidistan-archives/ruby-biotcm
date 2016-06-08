require_relative '../../test_helper'

describe BioTCM::Databases::OMIM do
  it 'return OMIM content' do
    assert_raises(ArgumentError) { BioTCM::Databases::OMIM.get('not_exist') }

    content = BioTCM::Databases::OMIM.get(100_070)
    assert_equal(100_070, content['mimNumber'])

    content = BioTCM::Databases::OMIM.get(179_760)
    assert_equal(179_760, content['mimNumber'])
  end

  it 'detect genes in OMIM text content' do
    content = BioTCM::Databases::OMIM.get(100_070)
    assert_includes(BioTCM::Databases::OMIM.detect_genes(content), 'MMP3')
  end
end
