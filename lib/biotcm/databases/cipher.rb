require 'fileutils'

# Cipher object gets top 1000 genes for each phenotype, 
# (described by OMIM ID), from one available Cipher website.
# The process of Cipher is simple and can be described by following steps:
# * fetch the disease list and the gene list
# * search and download the corresponding Cipher gene table of each OMIM ID
# * normalize gene identifiers to Approved Symbol and make them unique
#   * delete ones without approved symbols
#   * delete redundant symbols who rank lower
#
# = About Cipher
# Correlating protein Interaction network and PHEnotype network to pRedict 
# disease genes (CIPHER), is a computational framework that integrates human 
# protein–protein interactions, disease phenotype similarities, and known 
# gene–phenotype associations to capture the complex relationships between 
# phenotypes and genotypes.
#
# = Reference
# {http://www.nature.com/msb/journal/v4/n1/full/msb200827.html
# Xuebing Wu, Rui Jiang, Michael Q. Zhang, Shao Li. 
# Network-based global inference of human disease genes. 
# Molecular Systems Biology, 2008, 4:189.}
#
# @note TODO: Use BioTCM::Table here
#
class BioTCM::Databases::Cipher
  extend BioTCM::Modules::WorkingDir

  # Current version of Cipher
  VERSION = "0.1.0"
  # The url of Cipher website
  META_KEY = "CIPHER_WEBSITE_URL"

  # Initialize the Cipher object
  # @param omim_id [String, Array] omim id(s)
  # @example
  #   BioTCM::Databases::Cipher.new(["137280"])
  #   # => #<BioTCM::Databases::Cipher @genes.keys=["137280"]>
  def initialize(omim_id)
    # Ensurance
    BioTCM::Databases::HGNC.ensure
    base_url = BioTCM.get_meta(META_KEY)

    # Handle with omim_id
    omim_ids = case omim_id
               when String then [omim_id]
               when Array then omim_id
               else raise ArgumentError
               end

    # Load disease list
    @disease = {}
    filename = self.class.path_to("landscape_phenotype.txt")
    File.open(filename, 'w:UTF-8').puts BioTCM.get(base_url + "/landscape_phenotype.txt") unless File.exist?(filename)
    File.open(filename).each do |line|
      col = line.chomp.split("\t")
      @disease[col[1]] = col[0]
    end

    # Load gene list (inner_id2symbol)
    @gene = [nil]
    filename = self.class.path_to("landscape_extended_id.txt")
    File.open(filename, 'w:UTF-8').puts BioTCM.get(base_url + "/landscape_extended_id.txt") unless File.exist?(filename)
    File.open(filename).each do |line|
      col = line.chomp.split("\t")
      gene   = String.hgnc.symbol2hgncid[col[4]]
      gene ||= String.hgnc.uniprot2hgncid[col[2]]
      gene ||= String.hgnc.refseq2hgncid[col[3]]
      @gene.push(gene ? gene.hgncid2symbol : nil)
    end

    # Generate tables
    @table = {}
    omim_ids.flatten.uniq.each do |_omim_id|
      # Check
      unless /(?<omim_id>\d+)/ =~ _omim_id.to_s && @disease[omim_id]
        BioTCM.log.warn("Cipher") { "OMIM ID #{_omim_id.inspect} discarded, since it doesn't exist in the disease list of Cipher" }
        next
      end

      # Download if need
      filename = self.class.path_to("#{omim_id}.txt")
      File.open(filename, 'w:UTF-8').puts BioTCM.get(base_url + "/top1000data/#{@disease[omim_id]}.txt") unless File.exist?(filename)

      # Make table
      tab = "Approved Symbol\tCipher Rank\tCipher Score".to_table
      tab_genes = tab.instance_variable_get(:@row_keys)
      File.open(filename).each_with_index do |line, line_no|
        col = line.chomp.split("\t")
        gene = @gene[col[0].to_i] or next
        next if tab_genes[gene]
        tab.row(gene, [(line_no+1).to_s, col[1]])
      end
      @table[omim_id] = tab
    end
    
    BioTCM.log.debug("Cipher") { "New object " + self.inspect }
  end
  # Get contained omim ids
  # @return [Array]
  # @example
  #   cipher.omim_ids # => ["137280", ...]
  def omim_ids
    @table.keys
  end
  # Get the table of omim_id
  # @return [BioTCM::Table] Gene symbol as the primary key
  # @example
  #   cipher.table("137280").to_s
  #   # => 
  #
  def table(omim_id)
    @table[omim_id]
  end
  # Write tables to files
  # @param path [String] absolute path where to create files
  # @return [self]
  def export(path)
    FileUtils.mkdir_p(path)
    @table.each do |key, table|
      File.open(File.expand_path("#{key}.txt", path), 'w:UTF-8').puts table
    end
    return self
  end
  # @private
  def inspect
    "#<BioTCM::Databases::Cipher omim_ids=#{omim_ids}>"
  end
  # @private
  def to_s
    inspect
  end
end

BioTCM::Databases::Cipher.wd = BioTCM.path_to("data/cipher")
