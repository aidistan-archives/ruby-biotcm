require_relative '../test-helper'

class BioTCM_Databases_OMIM_Test < Test::Unit::TestCase
  context "OMIM" do
    should "return an hash storing OMIM objects if batch method called" do
      omim = BioTCM::Databases::OMIM.batch([100070, '100100', 'not_exist'])
      assert(omim.is_a? Hash)
      assert_equal(100070, omim[100070]['mimNumber'])
      assert_equal(100100, omim[100100]['mimNumber'])
      assert_equal(nil, omim['100100'])
      assert_equal(nil, omim['not_exist'])
    end

    should "store one entry for new method" do
      assert_raise(ArgumentError) do
        BioTCM::Databases::OMIM.new('not_exist')
      end
      omim = BioTCM::Databases::OMIM.new(100070)
      assert_equal(100070, omim['mimNumber'])
      assert(omim.genes.include? 'MMP3')
    end
  end
end



