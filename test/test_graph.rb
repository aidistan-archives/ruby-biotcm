require_relative 'test-helper'
require 'tempfile'

describe Graph do

  # Strict entry

  describe "when initialized with invalid edges" do
    it "must raise ArgumentError" do
      file = Tempfile.new('test')
      file.write "_source\t_interaction\t_target\tweight\n1\t->\t2\t1\n2\t-\t3\t2\n"
      file.flush
      assert_raises ArgumentError do
        net = Graph.new(file.path)
      end
      file.close!
    end
  end

  # Tolerant exit

  describe "when method called" do
    before do
      file = Tempfile.new('test')
      file.write "_source\t_interaction\t_target\n1\t--\t2\n2\t--\t3\n3\t--\t4\n4\t--\t1\n1\t--\t5\n5\t--\t3"
      file.flush
      @net = Graph.new(file.path)
      file.close!
    end

    it "must return a list of nodes or edges" do
      assert_equal(%w{1 2 3 4 5}, @net.node)
      assert_equal(%w{1--2 2--3 3--4 4--1 1--5 5--3}, @net.edge)
    end

    it "must return sub-graph given selected nodes" do
      assert_equal([], @net.select(["1", "3", "8"]).edge)
      assert_equal(["1--2", "2--3", "3--4", "4--1"], @net.select(["1", "2", "3", "4"]).edge)
    end

    it "must expand the graph given selected nodes" do
      assert_equal(@net.edge, @net.select(["1", "3", "8"]).expand.edge)
    end

    it "must knock down edges connected to selected nodes" do
      assert_equal(["1--2", "4--1", "1--5"], @net.knock_down(["3", "8"]).edge)
    end
  end
end
