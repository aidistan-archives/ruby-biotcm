require_relative '../test_helper'

describe BioTCM::Scripts::GeneDetector do
  it "must detect genes" do
    assert_equal(%w{TP53}, BioTCM::Scripts::GeneDetector.new.detect("TP53 is a critical gene during oncogenesis."))
  end
end
