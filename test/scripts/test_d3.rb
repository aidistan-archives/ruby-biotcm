# encoding: UTF-8
require_relative '../test-helper'
require 'tmpdir'

class BioTCM_Scripts_D3_Test < Test::Unit::TestCase
  context "D3 object" do
    should "raise error if unsupported chart type given" do
      assert_raise(ArgumentError) do
        BioTCM::Scripts::D3.new(File.dirname(__FILE__)).run(:foo)
      end

      # BioTCM::Scripts::D3.new(Dir.mktmpdir).demo(:bar).view
      # BioTCM::Scripts::D3.new(Dir.mktmpdir).demo(:grouped_bar).view
    end
  end
end
