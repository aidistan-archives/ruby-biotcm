require_relative '../test-helper'

describe BioTCM::Databases::OMIM do
  it "must return an hash storing OMIM objects if batch method called" do
    omim = BioTCM::Databases::OMIM.batch([100070, '100100', 'not_exist'])
    assert_instance_of(Hash, omim)
    assert_equal(100070, omim[100070]['mimNumber'])
    assert_equal(100100, omim[100100]['mimNumber'])
    assert_equal(nil, omim['100100'])
    assert_equal(nil, omim['not_exist'])
  end

  it "must store one entry for new method" do
    assert_raises(ArgumentError) { BioTCM::Databases::OMIM.new('not_exist') }
    omim = BioTCM::Databases::OMIM.new(100070)
    assert_equal(100070, omim['mimNumber'])
    assert_includes(omim.genes, 'MMP3')
  end
end
