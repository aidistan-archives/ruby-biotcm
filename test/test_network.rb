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
        assert_equal(["1", "2", "3"], @net.node);
        assert_equal(["1->2", "2--3"], @net.edge);
      end
    end
  end
end
