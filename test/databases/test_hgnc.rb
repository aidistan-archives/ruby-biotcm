require_relative '../test_helper'

describe BioTCM::Databases::HGNC do
  before do
    BioTCM::Databases::HGNC.ensure
    @hgnc  = String.hgnc
  end

  it "could convert identifiers in Hash way" do
    assert_equal("HGNC:100", @hgnc.symbol2hgncid["ASIC1"])
    assert_equal("HGNC:10001", @hgnc.entrez2hgncid["8490"])
    assert_equal("HGNC:10007", @hgnc.refseq2hgncid["NM_001278720"])
    assert_equal("HGNC:10004", @hgnc.uniprot2hgncid["O75916"])
    assert_equal("HGNC:10008", @hgnc.ensembl2hgncid["ENSG00000188672"])
    assert_equal("ASIC1", @hgnc.hgncid2symbol["HGNC:100"])
    assert_equal("8490", @hgnc.hgncid2entrez["HGNC:10001"])
    assert_equal("NM_001278720", @hgnc.hgncid2refseq["HGNC:10007"])
    assert_equal("O75916", @hgnc.hgncid2uniprot["HGNC:10004"])
    assert_equal("ENSG00000188672", @hgnc.hgncid2ensembl["HGNC:10008"])
  end

  it "could convert identifiers in method way" do
    assert_equal("HGNC:100", @hgnc.symbol2hgncid("ASIC1"))
    assert_equal("HGNC:10001", @hgnc.entrez2hgncid("8490"))
    assert_equal("HGNC:10007", @hgnc.refseq2hgncid("NM_001278720"))
    assert_equal("HGNC:10004", @hgnc.uniprot2hgncid("O75916"))
    assert_equal("HGNC:10008", @hgnc.ensembl2hgncid("ENSG00000188672"))
    assert_equal("ASIC1", @hgnc.hgncid2symbol("HGNC:100"))
    assert_equal("8490", @hgnc.hgncid2entrez("HGNC:10001"))
    assert_equal("NM_001278720", @hgnc.hgncid2refseq("HGNC:10007"))
    assert_equal("O75916", @hgnc.hgncid2uniprot("HGNC:10004"))
    assert_equal("ENSG00000188672", @hgnc.hgncid2ensembl("HGNC:10008"))
  end

  it "could formalize gene symbols" do
    assert_nil(@hgnc.formalize('Not a symbol'))
    assert_equal('TP53', @hgnc.formalize('p53'))
  end

  it "also would try to resuce unrecognized symbols" do
    assert_equal("HGNC:100", @hgnc.symbol2hgncid("ASIC-1"))
    assert_equal("HGNC:100", @hgnc.symbol2hgncid("Asic1"))
    assert_equal("HGNC:100", @hgnc.symbol2hgncid("Asic-1"))
  end
end


describe "With HGNC module" do
  before do
    BioTCM::Databases::HGNC.ensure
  end

  describe String do
    it "must need a dictionary" do
      hgnc, String.hgnc = String.hgnc, hgnc
      assert_raises(RuntimeError) { "".symbol2entrez }
      hgnc.as_dictionary
      assert_equal("", "".symbol2entrez)
    end

    it "must convert identifiers" do
      assert_equal("41", "ASIC1".symbol2entrez)
      assert_equal("RGS5", "8490".entrez2symbol)
      assert_equal("9028", "NM_003961".refseq2entrez)
      assert_equal("8787", "O75916".uniprot2entrez)
      assert_equal("6006", "ENSG00000188672".ensembl2entrez)
      assert_equal("", "".symbol2entrez)
    end

    it "must resuce unrecognized symbols" do
      assert_equal("41", "ASIC-1".symbol2entrez)
      assert_equal("41", "Asic1".symbol2entrez)
      assert_equal("41", "Asic-1".symbol2entrez)
    end
  end

  describe Array do
    it "must convert identifiers" do
      assert_equal(["ASIC1", "RGS4"], ["41", "5999"].entrez2symbol)
      assert_equal(["ASIC1", "RGS4"], [41, 5999].entrez2symbol)
    end
  end
end
