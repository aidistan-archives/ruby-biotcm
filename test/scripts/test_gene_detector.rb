require_relative '../test-helper'

class BioTCM_Scripts_GeneDetector_Test < Test::Unit::TestCase
  context "GeneDetector object" do
    should "detect genes" do
      assert_equal(%w{TP53}, BioTCM::Scripts::GeneDetector.new.detect("TP53 is a critical gene during oncogenesis."))
    end
  end
end
