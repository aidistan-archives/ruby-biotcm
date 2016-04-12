require 'biotcm/table'
require 'fileutils'

module BioTCM
  # A basic data model representing one layer, containing one node table and
  # one edge table.
  #
  # = Usage
  # Load a layer
  #
  #   layer = BioTCM::Layer.load('co-occurrence')
  #   #   co-occurrence/nodes.tab
  #   #   co-occurrence/edges.tab
  #
  #   layer = BioTCM::Layer.load('co-occurrence', prefix: '[20150405]')
  #   #   co-occurrence/[20150405]nodes.tab
  #   #   co-occurrence/[20150405]edges.tab
  #
  # Save the layer
  #
  #   layer.save('co-occurrence', prefix: '[20150405]')
  #   #   co-occurrence/[20150405]nodes.tab
  #   #   co-occurrence/[20150405]edges.tab
  #
  class Layer
    # Version
    VERSION = '0.2.0'

    # Table of nodes
    # @return [BioTCM::Table]
    attr_reader :node_tab
    # Table of edges
    # @return [BioTCM::Table]
    attr_reader :edge_tab

    # Load a layer from disk
    # @param path [String]
    # @param colname [Hash] A hash for column name mapping
    # @return [Layer]
    def self.load(
      path = nil,
      prefix: '',
      colname: {
        source: 'Source',
        target: 'Target',
        interaction: nil
      }
    )
      # Path convention
      if path
        edge_path = File.expand_path(prefix + 'edges.tab', path)
        node_path = File.expand_path(prefix + 'nodes.tab', path)
      end
      fin = File.open(edge_path)

      # Headline
      col = fin.gets.chomp.split("\t")
      unless (i_src = col.index(colname[:source]))
        raise ArgumentError, "Cannot find source node column: #{colname[:source]}"
      end
      unless (i_tgt = col.index(colname[:target]))
        raise ArgumentError, "Cannot find target node column: #{colname[:target]}"
      end
      col[i_src] = col[i_tgt] = nil
      if colname[:interaction]
        unless (i_typ = col.index(colname[:interaction]))
          raise ArgumentError, "Cannot find interaction type column: #{colname[:interaction]}"
        end
        col[i_typ] = nil
      else
        i_typ = nil
      end
      col.compact!

      # Initialize members
      node_tab = BioTCM::Table.new
      edge_tab = BioTCM::Table.new(primary_key: [colname[:source], colname[:interaction], colname[:target]].compact.join("\t"), col_keys: col)
      # Load edge_file
      node_in_table = node_tab.instance_variable_get(:@row_keys)
      col_size = edge_tab.col_keys.size
      fin.each do |line|
        col = line.chomp.split("\t")
        src = col[i_src]
        tgt = col[i_tgt]
        typ = i_typ ? col[i_typ] : nil

        # Insert nodes
        node_tab.row(src, []) unless node_in_table[src]
        node_tab.row(tgt, []) unless node_in_table[tgt]

        # Insert edge
        col[i_src] = col[i_tgt] = nil
        col[i_typ] = nil if i_typ
        col.compact!
        raise ArgumentError, "Row size inconsistent in line #{fin.lineno + 2}" unless col.size == col_size
        edge_tab.row([src, typ, tgt].compact.join("\t"), col)
      end

      # Load node_file
      if node_path
        tab = BioTCM::Table.load(node_path)
        node_tab.primary_key = tab.primary_key
        node_tab = node_tab.merge(tab)
      end

      new(edge_tab: edge_tab, node_tab: node_tab)
    end

    # Create a layer from an edge tab and a node tab
    # @param edge_tab [Table]
    # @param node_tab [Table]
    def initialize(edge_tab: nil, node_tab: nil)
      @edge_tab = edge_tab || BioTCM::Table.new(primary_key: "Source\tTarget")
      @node_tab = node_tab || BioTCM::Table.new(primary_key: 'Node')
    end

    # Save the layer to disk
    # @param path [String] path to output directory
    # @param prefix [String]
    def save(path, prefix = '')
      FileUtils.mkdir_p(path)
      @edge_tab.save(File.expand_path(prefix + 'edges.tab', path))
      @node_tab.save(File.expand_path(prefix + 'nodes.tab', path))
    end
  end
end
