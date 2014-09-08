require_relative '../test-helper'

class BioTCM_Scripts_Script_Test < Test::Unit::TestCase
  context "Script object" do
    should "raise NotImplementedError" do
      assert_raise NotImplementedError do
        BioTCM::Scripts::Script.new(File.dirname(__FILE__)).run
      end
    end
  end
end
