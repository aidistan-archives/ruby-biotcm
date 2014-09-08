require_relative '../test-helper'

class BioTCM_Modules_Utility_Test < Test::Unit::TestCase
  include BioTCM::Modules::Utility

  context "Utility module" do
    should "get web pages" do
      assert(get('http://www.baidu.com') =~ /^<!doctype html>/i)
      assert(get('unknown').nil?)
    end

    should "generate stamps" do
      stamp = get(:stamp)
      assert_not_match(/[^0-9a-zA-z\-_]/, stamp, 'Containing illegal character.')
      Thread.new { assert_not_equal(stamp, get(:stamp), 'Same stamps in different threads.') }.join.exit
    end
  end
end
