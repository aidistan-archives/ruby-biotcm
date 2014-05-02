# encoding: UTF-8
require_relative '../test-helper'

class BioTCM_Scripts_D3_Test < Test::Unit::TestCase
  context "D3 object" do
    should "raise error if unsupported chart type given" do
      assert_raise(ArgumentError) do
        BioTCM::Scripts::D3.new(File.dirname(__FILE__)).run(:foo)
      end

      # BioTCM::Scripts::D3.new(File.expand_path('../d3', __FILE__)).demo(:bar).view
    end
  end
end
