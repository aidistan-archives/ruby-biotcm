require 'rexml/document'

# KEGG module is designed for building PPI networks based on KEGG pathways.
#
# = Example Usage
# To get a pathway, use
#
#   BioTCM::Databases::KEGG.get_pathway('05010')
#   # => {
#     genes: [...],
#     network: [...],
#     associated_pathways: [...]
#   }
#
# = About KEGG
# KEGG is a database resource for understanding high-level functions and
# utilities of the biological system, such as the cell, the organism and the
# ecosystem, from molecular-level information, especially large-scale
# molecular datasets generated by genome sequencing and other high-throughput
# experimental technologies.
#
# = Reference
# 1. {http://www.genome.jp/kegg/ KEGG website}
# 2. {http://www.ncbi.nlm.nih.gov/pubmed/22080510 Kanehisa, M., Goto, S., Sato, Y., Furumichi, M., and Tanabe, M.; KEGG for integration and interpretation of large-scale molecular datasets. Nucleic Acids Res. 40, D109-D114 (2012).}
# 3. {http://www.ncbi.nlm.nih.gov/pubmed/10592173 Kanehisa, M. and Goto, S.; KEGG: Kyoto Encyclopedia of Genes and Genomes. Nucleic Acids Res. 28, 27-30 (2000).}
module BioTCM::Databases::KEGG
  # Current version of KEGG
  VERSION = '0.2.0'.freeze
  # KEGG default organism: Homo sapiens
  DEFAULT_ORGANISM = 'hsa'.freeze
  # KEGG identifer patterns
  PATTERNS = {
    organism: /^[a-z]{3,4}$/,
    pathway: {
      formal: /^[a-z]{3,4}\d{5}$/,
      alternative: /^\d{5}$/
    }
  }.freeze
  # Downloading url
  URLS = {
    pathway_kgml: ->(pathway_id) { "http://rest.kegg.jp/get/#{pathway_id}/kgml" },
    pathway_list: ->(organism) { "http://rest.kegg.jp/list/pathway/#{organism}" }
  }.freeze

  # Validate the pathway_id
  # @param pathway_id [String]
  # @param organism [String]
  # @return [String] Valid pathway ID, nil returned if unable to validate)
  # @raise ArgumentError Raised if organism invalid
  def self.validate_pathway_id(pathway_id, organism = DEFAULT_ORGANISM)
    raise ArgumentError, 'Invalid organism' unless organism =~ PATTERNS[:organism]
    case pathway_id
    when PATTERNS[:pathway][:formal]      then pathway_id
    when PATTERNS[:pathway][:alternative] then organism + pathway_id
    else return nil
    end
  end

  # Check if pathway_id is a valid KEGG pathway id
  # @return [Boolean]
  def self.valid_pathway_id?(pathway_id)
    return true if pathway_id =~ PATTERNS[:pathway][:formal]
    return true if pathway_id =~ PATTERNS[:pathway][:alternative]
    false
  end

  # Get the list of all pathways of given organism
  # @param organism [String]
  # @return [Array]
  # @raise ArgumentError
  def self.get_pathway_list(organism = DEFAULT_ORGANISM)
    raise ArgumentError, 'Invalid organism' unless organism =~ PATTERNS[:organism]

    file_path = BioTCM.path_to("kegg/list_#{organism}.txt")
    unless File.exist?(file_path)
      fout = File.open(file_path, 'w')
      fout.puts BioTCM.curl(URLS[:pathway_list].call(organism))
      fout.close
    end

    # Yield the pattern of pathway ids
    pattern = Regexp.new("^path:(#{organism}#{PATTERNS[:pathway][:alternative].source[1...-1]})")
    File.open(file_path).map do |line|
      line.match(pattern) ? Regexp.last_match[1] : nil
    end.compact
  end

  # Get the pathway specified by pathway_id
  # @param pathway_id [String] KEGG pathway id (using {DEFAULT_ORGANISM} if not specified)
  # @return [Pathway]
  # @raise RuntimeError if pathway_id not exist
  def self.get_pathway(pathway_id)
    raise ArgumentError, 'Invalid pathway_id' unless (pathway_id = validate_pathway_id(pathway_id))

    file_path = BioTCM.path_to("kegg/#{pathway_id}.xml")
    unless File.exist?(file_path)
      BioTCM.logger.info('KEGG') { "Downloading the KGML of pathway #{pathway_id.inspect} from KEGG" }
      content = BioTCM.curl(URLS[:pathway_kgml].call(pathway_id))
      fout = File.open(file_path, 'w')
      fout.puts(content)
      fout.close
    end
    doc = REXML::Document.new(File.open(file_path).readlines.join)
    pathway = { genes: [], network: [], associated_pathways: [] }

    # Get entry list
    entry_list = {}
    doc.elements.each('pathway/entry') do |entry|
      entry_id = entry.attributes['id']
      case entry.attributes['type']
      when 'gene'
        entry_list[entry_id] = { type: :gene, genes: [] }
        entry.attributes['name'].scan(/hsa:(\d+)/) { |match| entry_list[entry_id][:genes] << match[0] }
      when 'group'
        entry_list[entry_id] = { type: :group, components: [], genes: [] }
        entry.elements.each('component') do |component|
          entry_list[entry_id][:components] << component.attributes['id']
        end
      when 'map'
        entry_list[entry_id] = { type: :map, genes: [] }
        /path:(?<map>\w+)/ =~ entry.attributes['name']
        entry_list[entry_id][:map] = map
        pathway[:associated_pathways] << map
      end
    end

    # Build pathway.genes & process group entry
    entry_list.each_value do |hash|
      case hash[:type]
      when :gene
        hash[:genes].each { |gene| pathway[:genes] << gene }
      when :group
        # Link genes between entries
        hash[:components].combination(2).each do |comb|
          entry_list[comb[0]][:genes].each do |gene0|
            entry_list[comb[1]][:genes].each do |gene1|
              pathway[:network] << [gene0, gene1] << [gene1, gene0]
            end
          end
        end
        # Build gene list for the group
        hash[:components].each { |entry_id| hash[:genes] += entry_list[entry_id][:genes] }
        hash[:genes].uniq!
      end
    end

    # Get entry relation list
    entry_relation_list = []
    doc.elements.each('pathway/relation') do |relation|
      next unless entry_list.key?(relation.attributes['entry1'])
      next unless entry_list.key?(relation.attributes['entry2'])

      # One-direction or two-direction
      relation.elements.each('subtype') do |subtype|
        case subtype.attributes['value']
        when '-->', '--|', '..>', '+p', '-p', '+g', '+u', '+m'
          entry_relation_list << [relation.attributes['entry1'], relation.attributes['entry2']]
          break
        when '...', '---'
          entry_relation_list << [relation.attributes['entry1'], relation.attributes['entry2']]
          entry_relation_list << [relation.attributes['entry2'], relation.attributes['entry1']]
          break
        end
      end
    end

    # Load relation into :network
    entry_relation_list.each do |pair|
      entry_list[pair[0]][:genes].each do |gene1|
        entry_list[pair[1]][:genes].each do |gene2|
          pathway[:network].push [gene1, gene2]
        end
      end
    end

    pathway[:genes].uniq!
    pathway[:network].uniq!
    pathway
  end
end
