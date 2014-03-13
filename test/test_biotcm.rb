#!/usr/bin/env ruby
# encoding: UTF-8
require 'test/unit'
require 'shoulda-context'
require 'biotcm'

class BioTCM_Test < Test::Unit::TestCase
  context "BioTCM module" do
    should "have such hierarchy" do
      assert_nothing_raised do
        BioTCM::Modules
        BioTCM::Databases
      end
    end
  end
end
