# encoding: UTF-8
require 'biotcm/table'

module BioTCM
  # One of the basic data models used in BioTCM to process network/graph
  # files, developed under <b>"strict entry and tolerant exit"</b> 
  # philosophy (please refer to the test for details). 
  class BioTCM::Network
    # List of nodes
    attr_reader :node
    def node
      @node || @node_table.row_keys
    end
    # List of edges
    attr_reader :edge
    def edge
      @edge || @edge_table.row_keys
    end
    # Table of all nodes
    attr_reader :node_table
    # Table of all edges
    attr_reader :edge_table
    # Create a network from file(s)
    # @param edge_file [String] file path
    # @param node_file [String ]file path
    def initialize(edge_file, node_file = nil,  # TOFIX: process node_file please
        column_source_node:"_source", 
        column_interaction_type:"_interaction", 
        column_target_node:"_target"
    )
      fin = File.open(edge_file)
      
      # Headline
      col = fin.gets.chomp.split("\t")
      i_src = col.index(column_source_node) or raise ArgumentError, "Cannot find source node column: #{column_source_node}"
      i_typ = col.index(column_interaction_type) or raise ArgumentError, "Cannot find interaction type column: #{column_interaction_type}"
      i_tgt = col.index(column_target_node) or raise ArgumentError, "Cannot find target node column: #{column_target_node}"
      col[i_src] = nil; col[i_typ] = nil; col[i_tgt] = nil; col.compact!
      
      # Initialize members
      @node_table = BioTCM::Table.new
      @node_table.primary_key = "Node"
      @edge_table = BioTCM::Table.new
      @edge_table.primary_key = "Edge"
      col.each { |c| @edge_table.col(c, {}) }

      # Read
      node_in_table = @node_table.instance_variable_get(:@row_keys)
      col_size = col.size
      fin.each_with_index do |line, line_no|
        col = line.chomp.split("\t")
        raise ArgumentError, "Unrecognized interaction type: #{col[i_typ]}" unless ['--', '->'].include?(col[i_typ])
        src = col[i_src]; typ = col[i_typ]; tgt = col[i_tgt];
        # Insert nodes
        @node_table.row(src, []) unless node_in_table[src]
        @node_table.row(tgt, []) unless node_in_table[tgt]
        # Insert edge
        col[i_src] = nil; col[i_typ] = nil; col[i_tgt] = nil; col.compact!
        raise ArgumentError, "Row size inconsistent in line #{line_no+2}" unless col.size == col_size
        @edge_table.row(src+typ+tgt, col)
      end
    end
  end
end