require_relative 'test_helper'

describe BioTCM do
  it "must be able to get meta data" do
    assert_equal('META file', BioTCM.get_meta('BioTCM'))
  end
end
