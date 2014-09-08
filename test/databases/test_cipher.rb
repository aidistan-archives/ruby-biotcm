require_relative '../test-helper'

class BioTCM_Databases_Cipher_Test < Test::Unit::TestCase
  context "Cipher object" do
    setup do
      @cipher = BioTCM::Databases::Cipher.new(['137280', '100050'])
    end

    should "return omim ids" do
      assert_equal(['137280', '100050'], @cipher.omim_ids)
    end

    should "build gene tables" do
      assert(@cipher.table('137280').is_a?(BioTCM::Table))
      assert_equal({"Cipher Rank"=>"38", "Cipher Score"=>"0.064086"}, @cipher.table('137280').row('TP53'))
    end
  end
end
