require_relative '../../test_helper'

describe BioTCM::Apps::PubmedGeneMiner do
  before do
    @miner = BioTCM::Apps::PubmedGeneMiner.new(gene_set: ['IL-2'])
  end

  it 'mine genes online' do
    res = @miner.mine_online('(IBD[Title/Abstract]) OR (CRC[Title/Abstract]) AND Cancer[Title/Abstract]')
    assert_instance_of(Hash, res)
    assert(res['IL2'] > 0)
  end

  it 'mine genes offline' do
    res = @miner.mine_offline('(IBD[Title/Abstract]) OR (CRC[Title/Abstract]) AND Cancer[Title/Abstract] AND Obesity[Title/Abstract] AND IL-2[Title/Abstract]')
    assert_instance_of(Hash, res)
    assert(res['IL2'] > 0)
  end
end
