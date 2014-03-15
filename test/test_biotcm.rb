# encoding: UTF-8
require_relative 'test-helper'

class BioTCM_Test < Test::Unit::TestCase
  context "BioTCM module" do
    should "have such hierarchy" do
      assert_nothing_raised do
        BioTCM::Modules
        BioTCM::Databases
      end
    end

    should "be able to get meta" do
      assert_equal('META file', BioTCM.get_meta('BioTCM'))
    end
  end
end
