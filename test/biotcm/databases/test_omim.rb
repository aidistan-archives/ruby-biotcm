require_relative '../../test_helper'

describe BioTCM::Databases::OMIM do
  it 'must return an hash storing OMIM objects if batch method called' do
    omim = BioTCM::Databases::OMIM.batch([100_070, '100100', 'not_exist'])
    assert_instance_of(Hash, omim)
    assert_equal(100_070, omim[100_070]['mimNumber'])
    assert_equal(100_100, omim[100_100]['mimNumber'])
    assert_equal(nil, omim['100100'])
    assert_equal(nil, omim['not_exist'])
  end

  it 'must store one entry for new method' do
    assert_raises(ArgumentError) { BioTCM::Databases::OMIM.new('not_exist') }

    omim = BioTCM::Databases::OMIM.new(100_070)
    assert_equal(100_070, omim['mimNumber'])
    assert_includes(omim.genes, 'MMP3')

    omim = BioTCM::Databases::OMIM.new(179_760)
    assert_equal(179_760, omim['mimNumber'])
  end
end
