require_relative '../test_helper'

include BioTCM::Modules::Utility

describe BioTCM::Modules::Utility do
  it "must get web pages" do
    assert_match(/^<!doctype html>/i, get('http://biotcm.github.io'))
    assert_nil(get('unknown'))
  end

  it "must generate time stamps" do
    stamp = get(:stamp)
    refute_match(/[^0-9a-zA-z\-_]/, stamp, 'Containing illegal character.')
    Thread.new { refute_equal(stamp, get(:stamp), 'Same stamps in different threads.') }.join.exit
  end
end
