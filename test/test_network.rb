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
      @net = BioTCM::Network.new(File.expand_path("../network_background.txt", __FILE__))
    end

    context "basic operations, we" do

      should "be able to access the list of nodes and edges" do
        assert_equal(%w{1 2 3 4 5}, @net.node)
        assert_equal(%w{1--2 2--3 3--4 4--1 1--5 5--3}, @net.edge)
      end

      should "be able to select sub-network given selected nodes" do
        assert_equal([], @net.select(["1", "3", "8"]).edge)
        assert_equal(["1--2", "2--3", "3--4", "4--1"], @net.select(["1", "2", "3", "4"]).edge)
      end

      should "be able to expand network given selected nodes" do
        assert_equal(@net.edge, @net.select(["1", "3", "8"]).expand.edge)
      end

      should "be able to knock down edges connected to selected nodes" do
        assert_equal(["1--2", "4--1", "1--5"], @net.knock_down(["3", "8"]).edge)
      end
    end
  end
end
