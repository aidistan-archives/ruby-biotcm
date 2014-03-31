# encoding: UTF-8
require_relative '../test-helper'

class BioTCM_Databases_Medline_Test < Test::Unit::TestCase
  context "Using Medline, we" do
    should "be able to query PubMed with specific terms" do 
      assert(BioTCM::Databases::Medline.new("IL-2 IBD").count > 0)
    end

    should "be able to query PubMed with logical operations" do
      assert_nothing_raised do
        @medline = BioTCM::Databases::Medline.new("IL-2 IBD")
        @medline | "IL-2 CRC"
        @medline & "Cancer"
      end
      assert(@medline.count > 0)
    end

    should "be able to download the query result" do
      filename = __FILE__+'.tmp'
      assert_nothing_raised do
        BioTCM::Databases::Medline.new("IL-2 IBD CRC").download(filename)
      end
      File.open(filename) { |fin| assert(fin.readlines.size > 0) }
      File.delete(filename)
    end
  end
end
