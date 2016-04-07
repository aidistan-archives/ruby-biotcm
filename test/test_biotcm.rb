require_relative 'test_helper'

describe BioTCM do
  it 'must be able to get meta data' do
    assert_equal('meta.json', BioTCM.meta['__filename'])
  end
end
