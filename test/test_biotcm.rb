# encoding: UTF-8
require_relative 'test_helper'

class BioTCM_Test < Test::Unit::TestCase
  context "BioTCM module" do
    should "have such hierarchy" do
      assert_nothing_raised do
        BioTCM::Modules
        BioTCM::Databases
      end
    end
  end
end
