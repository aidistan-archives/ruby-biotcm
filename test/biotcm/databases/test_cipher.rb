require_relative '../../test_helper'

describe BioTCM::Databases::Cipher do
  before do
    @cipher = BioTCM::Databases::Cipher.get('137280')
  end

  it 'must return the gene table' do
    assert_instance_of(BioTCM::Table, @cipher)
  end
end
