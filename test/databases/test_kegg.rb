require_relative '../test-helper'

class BioTCM_Databases_KEGG_Test < Test::Unit::TestCase
  context "KEGG" do
    should "raise error if given pathway not exists" do
      assert_raise(ArgumentError) { BioTCM::Databases::KEGG.get_pathway("00000") }
    end
    should "download KGMLs" do
      filename = BioTCM::Databases::KEGG.path_to("hsa05010.xml")
      File.delete filename if FileTest.exist?(filename)
      BioTCM::Databases::KEGG.get_pathway("05010")
      assert(FileTest.exist?(filename))
    end

    context "instance" do
      should "load KGMLs and create Pathway objects" do
        kegg = BioTCM::Databases::KEGG.new("05010")
        assert(kegg.pathways["hsa05010"])
      end
      should "have more pathways if extended (in most cases)" do
        kegg = BioTCM::Databases::KEGG.new("05010")
        before = kegg.pathways.size
        kegg.extend_to_associated
        assert(kegg.pathways.size > before)
      end
    end
  end
end
