# encoding: UTF-8
require_relative 'test-helper'
require 'tempfile'

class BioTCM_Network_Test < Test::Unit::TestCase

  context "[Strict entry] When initialized with" do

    context "invalid edges, Network" do
      should "raise ArgumentError" do
        file = Tempfile.new('test')
        file.write "edge\tweight\n1->2\t1\n2-3\t1\n"
        file.rewind
        assert_raise ArgumentError do
          BioTCM::Table.new(file.path)
        end
        file.close!
      end
	context "confused network type, Network"
      should "raise ArgumentError" do
        file = Tempfile.new('test')
        file.write "edge\tweight\n1->2\t1\n2--3\t1\n"
        file.rewind
        assert_raise ArgumentError do
          BioTCM::Table.new(file.path)
        end
        file.close!
      end
	end
	
  end
  
end
