# encoding: UTF-8
require_relative 'test-helper'
require 'tempfile'

class BioTCM_Network_Test < Test::Unit::TestCase

  context "[Strict entry] When initialized with" do
    context "invalid edges, Network" do
      should "raise ArgumentError" do
        file = Tempfile.new('test')
        file.write "_source\t_interaction\t_target\tweight\n1\t->\t2\t1\n2\t-\t3\t2\n"
        file.rewind
        assert_raise ArgumentError do
          net = BioTCM::Network.new(file.path)
        end
        file.close!
      end
    end
  end

  context "[Tolerant exit] As for " do
    setup do
      file = Tempfile.new('test')
      file.write "_source\t_interaction\t_target\tweight\n1\t->\t2\t1\n2\t--\t3\t2\n"
      file.rewind
      @net = BioTCM::Network.new(file.path)
      file.close!
    end

    context "basic operations, we" do
      should "be able to access the list of nodes and edges" do
        assert_equal(["1", "2", "3"], @net.node)
        assert_equal(["1->2", "2--3"], @net.edge)
      end
    end
    
    context "basic functions, we" do 
      setup do
        @net = BioTCM::Network.new("test_network_background.txt")
      end
      should "select correct network according to input nodes" do
        assert_equal(nil, @net.select(["1", "3"]).edge)
        expected = ["1--2", "2--3", "3--4", "4--1"]
        actual = @net.select(["1", "2", "3", "4"]).edge
        assert_equal(expected,  expected&actual)
        assert_equal(expected,  expected|actual)
      end
      should "expand network according selected nodes" do
        assert_equal(@net.edge, @net.select(["1", "3"]).edge.expand)
      end
    end
  end
  
end
