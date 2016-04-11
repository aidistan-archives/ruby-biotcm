require_relative 'test_helper'

describe BioTCM do
  it 'must get meta data' do
    assert_equal('meta.json', BioTCM.meta['__filename'])
  end

  it 'must curl urls' do
    assert_match(/^<!doctype html>/i, BioTCM.curl('http://www.baidu.com/'))
    assert_nil(BioTCM.curl('unknown'))
  end

  it 'must generate stamps' do
    stamp = BioTCM.stamp
    refute_match(/[^0-9a-zA-z\-_]/, stamp, 'Containing illegal character.')
    Thread.new { refute_equal(stamp, BioTCM.stamp, 'Same stamps in different threads.') }.join.exit
  end
end
