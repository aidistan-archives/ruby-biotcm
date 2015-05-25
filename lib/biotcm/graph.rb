require 'biotcm/table'

# One of the basic data models used in BioTCM to process graph/network
# files, developed under <b>"strict entry and tolerant exit"</b> philosophy.
#
# Please refer to the test for details.
#
# @deprecated
#
class Graph
  # Valide interaction types
  INTERACTION_TYPES = ['--', '->']
  # List of nodes
  attr_reader :node
  def node
    @node.keys
  end
  # List of edges
  attr_reader :edge
  def edge
    @edge.keys
  end
  # Table of all nodes
  attr_reader :node_table
  # Table of all edges
  attr_reader :edge_table
  # Create a graph from file(s)
  # @param edge_file [String] file path
  # @param node_file [String] file path
  def initialize(edge_file, node_file = nil,
      column_source_node:'_source',
      column_interaction_type:'_interaction',
      column_target_node:'_target'
  )
    fin = File.open(edge_file)

    # Headline
    col = fin.gets.chomp.split("\t")
    unless (i_src = col.index(column_source_node))
      fail ArgumentError, "Cannot find source node column: #{column_source_node}"
    end
    unless (i_typ = col.index(column_interaction_type))
      fail ArgumentError, "Cannot find interaction type column: #{column_interaction_type}"
    end
    unless (i_tgt = col.index(column_target_node))
      fail ArgumentError, "Cannot find target node column: #{column_target_node}"
    end
    col[i_src] = col[i_typ] = col[i_tgt] = nil
    col.compact!

    # Initialize members
    @node_table = BioTCM::Table.new
    @node_table.primary_key = 'Node'
    @edge_table = BioTCM::Table.new
    @edge_table.primary_key = 'Edge'
    col.each { |c| @edge_table.col(c, {}) }

    # Load edge_file
    node_in_table = @node_table.instance_variable_get(:@row_keys)
    col_size = @edge_table.col_keys.size
    fin.each_with_index do |line, line_no|
      col = line.chomp.split("\t")
      unless INTERACTION_TYPES.include?(col[i_typ])
        fail ArgumentError, "Unrecognized interaction type: #{col[i_typ]}"
      end
      src = col[i_src]
      typ = col[i_typ]
      tgt = col[i_tgt]
      # Insert nodes
      @node_table.row(src, []) unless node_in_table[src]
      @node_table.row(tgt, []) unless node_in_table[tgt]
      # Insert edge
      col[i_src] = col[i_typ] = col[i_tgt] = nil
      col.compact!
      fail ArgumentError, "Row size inconsistent in line #{line_no + 2}" unless col.size == col_size
      @edge_table.row(src + typ + tgt, col)
    end

    # Load node_file
    if node_file
      node_table = BioTCM::Table.new(node_file)
      @node_table.primary_key = node_table.primary_key
      @node_table = @node_table.merge(node_table)
    end

    # Set members
    @node = @node_table.instance_variable_get(:@row_keys).clone
    @edge = @edge_table.instance_variable_get(:@row_keys).clone
  end
  # Clone the graph but share the same background
  # @return [Graph]
  def clone
    net = super
    net.instance_variable_set(:@node, @node.clone)
    net.instance_variable_set(:@edge, @edge.clone)
    net
  end
  # Get a graph with selected nodes and edges between them
  # @return [Graph]
  def select(list)
    clone.select!(list)
  end
  # Leaving selected nodes and edges between them
  # @return [self]
  def select!(list)
    # Node
    (@node.keys - list).each { |k| @node.delete(k) }
    # Edge
    regexp = Regexp.new(INTERACTION_TYPES.join('|'))
    @edge.select! do |edge|
      src, tgt = edge.split(regexp)
      @node[src] && @node[tgt] ? true : false
    end
    self
  end
  # Get a expanded graph
  # @return [Graph]
  def expand(step = 1)
    clone.expand!(step)
  end
  # Expand self
  # @return [self]
  def expand!(step = 1)
    step.times { expand } if step > 1
    all_node = @node_table.instance_variable_get(:@row_keys)
    old_node = @node
    @node = {}
    # Edge
    regexp = Regexp.new(INTERACTION_TYPES.join('|'))
    @edge_table.instance_variable_get(:@row_keys).each do |edge, edge_index|
      next if @edge[edge]
      src, tgt = edge.split(regexp)
      next unless old_node[src] || old_node[tgt]

      @edge[edge] = edge_index
      @node[src] = all_node[src] unless @node[src]
      @node[tgt] = all_node[tgt] unless @node[tgt]
    end
    self
  end
  # Get a graph without given nodes
  # @return [Graph]
  def knock_down(list)
    clone.knock_down!(list)
  end
  # Knock given nodes down
  # @return [self]
  def knock_down!(list)
    self.select!(node - list)
  end
end
