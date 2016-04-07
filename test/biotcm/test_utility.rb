require_relative '../test_helper'

describe BioTCM::Utility do
  it 'could curl urls' do
    assert_match(/^<!doctype html>/i, BioTCM::Utility.curl('http://biotcm.github.io/'))
    assert_nil(BioTCM::Utility.curl('unknown'))
  end

  it 'could generate stamps' do
    stamp = BioTCM::Utility.stamp
    refute_match(/[^0-9a-zA-z\-_]/, stamp, 'Containing illegal character.')
    Thread.new { refute_equal(stamp, BioTCM::Utility.stamp, 'Same stamps in different threads.') }.join.exit
  end
end
