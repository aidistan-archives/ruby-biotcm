require_relative '../../test_helper'

describe BioTCM::Databases::HGNC do
  hgnc = BioTCM::Databases::HGNC.load

  it 'could convert identifiers in Hash way' do
    assert_equal('HGNC:100', hgnc.symbol2hgncid['ASIC1'])
    assert_equal('HGNC:10001', hgnc.entrez2hgncid['8490'])
    assert_equal('HGNC:10007', hgnc.refseq2hgncid['XM_017023849'])
    assert_equal('HGNC:10004', hgnc.uniprot2hgncid['O75916'])
    assert_equal('HGNC:10008', hgnc.ensembl2hgncid['ENSG00000188672'])
    assert_equal('ASIC1', hgnc.hgncid2symbol['HGNC:100'])
    assert_equal('8490', hgnc.hgncid2entrez['HGNC:10001'])
    assert_equal('XM_017023849', hgnc.hgncid2refseq['HGNC:10007'])
    assert_equal('O75916', hgnc.hgncid2uniprot['HGNC:10004'])
    assert_equal('ENSG00000188672', hgnc.hgncid2ensembl['HGNC:10008'])
  end

  it 'could convert identifiers in method way' do
    assert_equal('HGNC:100', hgnc.symbol2hgncid('ASIC1'))
    assert_equal('HGNC:10001', hgnc.entrez2hgncid('8490'))
    assert_equal('HGNC:10007', hgnc.refseq2hgncid('XM_017023849'))
    assert_equal('HGNC:10004', hgnc.uniprot2hgncid('O75916'))
    assert_equal('HGNC:10008', hgnc.ensembl2hgncid('ENSG00000188672'))
    assert_equal('ASIC1', hgnc.hgncid2symbol('HGNC:100'))
    assert_equal('8490', hgnc.hgncid2entrez('HGNC:10001'))
    assert_equal('XM_017023849', hgnc.hgncid2refseq('HGNC:10007'))
    assert_equal('O75916', hgnc.hgncid2uniprot('HGNC:10004'))
    assert_equal('ENSG00000188672', hgnc.hgncid2ensembl('HGNC:10008'))
  end

  it 'also would try to resuce unrecognized symbols' do
    assert_equal('HGNC:100', hgnc.symbol2hgncid('ASIC-1'))
    assert_equal('HGNC:100', hgnc.symbol2hgncid('Asic1'))
    assert_equal('HGNC:100', hgnc.symbol2hgncid('Asic-1'))
  end
end

describe 'With HGNC module' do
  BioTCM::Databases::HGNC.load.as_dictionary

  describe String do
    it 'could convert identifiers' do
      assert_equal('41', 'ASIC1'.symbol2entrez)
      assert_equal('RGS5', '8490'.entrez2symbol)
      assert_equal('9028', 'NM_003961'.refseq2entrez)
      assert_equal('8787', 'O75916'.uniprot2entrez)
      assert_equal('6006', 'ENSG00000188672'.ensembl2entrez)
      assert_equal('', ''.symbol2entrez)
    end

    it 'could resuce unrecognized symbol' do
      assert_equal('41', 'ASIC-1'.symbol2entrez)
      assert_equal('41', 'Asic1'.symbol2entrez)
      assert_equal('41', 'Asic-1'.symbol2entrez)
    end

    it 'could formalize gene symbol' do
      assert_equal('TP53', 'p-53'.to_formal_symbol)
    end
  end

  describe Array do
    it 'could convert identifiers' do
      assert_equal(%w(ASIC1 RGS4), %w(41 5999).entrez2symbol)
      assert_equal(%w(ASIC1 RGS4), [41, 5999].entrez2symbol)
    end

    it 'could formalize gene symbols' do
      assert_equal(%w(TP53 TP53), ['p-53', 'P-53'].to_formal_symbols)
    end
  end
end
