# encoding: UTF-8
require_relative '../test_helper'

class BioTCM_Modules_Utility_Test < Test::Unit::TestCase
  include BioTCM::Modules::Utility

  context "Utility module" do
    should "have a useful :get method" do
      assert(get('http://www.baidu.com') =~ /^<!doctype html>/i)
      assert(get('unknown').nil?)
    end

    should "generate stamps" do
      stamp = get_stamp
      assert_not_match(/[^0-9a-zA-z\-_]/, stamp, 'Containing illegal character.')
      Thread.new { assert_not_equal(stamp, get_stamp, 'Same stamps in different threads.') }.join.exit
    end
  end
end
