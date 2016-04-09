# Cipher object gets top 1000 genes for each phenotype (identified by OMIM ID),
# from one available Cipher website and stores the results as a hash.
#
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
# protein-protein interactions, disease phenotype similarities, and known
# gene-phenotype associations to capture the complex relationships between
# phenotypes and genotypes.
#
# = Reference
# {http://www.nature.com/msb/journal/v4/n1/full/msb200827.html
# Xuebing Wu, Rui Jiang, Michael Q. Zhang, Shao Li.
# Network-based global inference of human disease genes.
# Molecular Systems Biology, 2008, 4:189.}
#
module BioTCM::Databases::Cipher
  # Current version of Cipher
  VERSION = '0.3.0'
  # The url of Cipher website
  META_KEY = 'CIPHER_WEBSITE_URL'

  # Get Cipher results
  # @param omim_id [String]
  # @return [Table]
  # @example
  #   BioTCM::Databases::Cipher.get(137280) => #<Table ...>
  def self.get(omim_id)
    # Ensurance
    BioTCM::Databases::HGNC.ensure
    base_url = BioTCM.meta[META_KEY]

    # Load disease list
    @disease = {}
    filename = BioTCM.path_to('cipher/landscape_phenotype.txt')
    File.open(filename, 'w:UTF-8').puts BioTCM.curl(base_url + '/landscape_phenotype.txt') unless File.exist?(filename)
    File.open(filename).each do |line|
      col = line.chomp.split("\t")
      @disease[col[1]] = col[0]
    end

    # Load gene list (inner_id2symbol)
    @gene = [nil]
    filename = BioTCM.path_to('cipher/landscape_extended_id.txt')
    File.open(filename, 'w:UTF-8').puts BioTCM.curl(base_url + '/landscape_extended_id.txt') unless File.exist?(filename)
    File.open(filename).each do |line|
      col = line.chomp.split("\t")
      gene   = String.hgnc.symbol2hgncid[col[4]]
      gene ||= String.hgnc.uniprot2hgncid[col[2]]
      gene ||= String.hgnc.refseq2hgncid[col[3]]
      @gene.push(gene ? gene.hgncid2symbol : nil)
    end

    # Check omim id
    original_omim_id = omim_id
    unless /(?<omim_id>\d+)/ =~ original_omim_id.to_s && @disease[omim_id]
      BioTCM.logger.warn('Cipher') { "OMIM ID #{original_omim_id.inspect} discarded, since it doesn't exist in the disease list of Cipher" }
      return nil
    end

    # Download if need
    filename = BioTCM.path_to("cipher/#{omim_id}.txt")
    File.open(filename, 'w:UTF-8').puts BioTCM.curl(base_url + "/top1000data/#{@disease[omim_id]}.txt") unless File.exist?(filename)

    # Make table
    tab = "Gene\tCipher Rank\tCipher Score".to_table
    tab_genes = tab.instance_variable_get(:@row_keys)
    File.open(filename).each_with_index do |line, line_no|
      col = line.chomp.split("\t")
      gene = @gene[col[0].to_i] or next
      next if tab_genes[gene]
      tab.row(gene, [(line_no + 1).to_s, col[1]])
    end

    tab
  end
end
