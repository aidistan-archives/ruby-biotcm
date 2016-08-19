# To mine gene relationships from PubMed
#
# = Example Usage
#
#   miner = BioTCM::Apps::PubmedGeneMiner.new
#   miner.mine_offline('(IBD[Title/Abstract]) OR (CRC[Title/Abstract]) AND Cancer[Title/Abstract] AND Obesity[Title/Abstract] AND IL-2[Title/Abstract]')
#   # => {"MID1"=>["25975416"], "IL2"=>["25975416"], "HR"=>["25975416"], "NDUFB6"=>["25975416"], "CXCL8"=>["25975416"]}
#
class BioTCM::Apps::PubmedGeneMiner
  # Current version
  VERSION = '0.2.0'.freeze

  # Setup a new miner
  # @param params options for the new miner
  # @option params :gene_set [Array] ([...]) a set of genes we concern
  # @option params :branching_point [Fixnum] (10000) decide the strategy upon the number of abstracts
  # @option params :mining_strategy [Symbol] (nil) use given strategy regardless of the number of abstracts, possible values are:
  #   - nil
  #   - :online
  #   - :offline
  def initialize(params = {})
    BioTCM::Databases::HGNC.ensure

    @branching_point = params[:branching_point] || 10_000
    @mining_strategy = params[:mining_strategy]

    if params[:gene_set]
      @gene_set = params[:gene_set].to_formal_symbols - ['']
    else
      hgnc = BioTCM::Databases::HGNC
      gene_blacklist = Regexp.new('(' + BioTCM::Apps::GeneDetector::DEFAULT_GENE_BLACKLIST.join(')|(') + ')')
      @gene_set = (hgnc.symbol2hgncid.keys - hgnc.ambiguous_symbol.keys).reject { |gene| gene =~ gene_blacklist }
    end
  end

  # Mine gene relationships
  #
  # Mining strategy will be decided by given :mining_strategy or
  # given :branching_point
  def mine(query)
    case @mining_strategy
    when :online then mine_online(query)
    when :offline then mine_offline(query)
    else
      if as_medline(query).count > @branching_point
        mine_online(query)
      else
        mine_offline(query)
      end
    end
  end

  # Mine gene relationships online
  #
  # Query medline by enumerate all term-gene pairs
  def mine_online(query)
    term = as_medline(query).term

    @gene_set.map do |gene|
      [gene, BioTCM::Databases::Medline.new("(#{term}) AND #{gene}[Title/Abstract]").fetch_pubmed_ids]
    end.to_h
  end

  # Mine gene relationships offline
  #
  # Donwload abstracts and then count genes
  def mine_offline(query)
    @gene_detector = BioTCM::Apps::GeneDetector.new

    datapath = BioTCM.path_to("tmp/PubmedGeneMiner.#{BioTCM.stamp}.txt")
    as_medline(query).download_abstracts(datapath)

    res = {}
    counter = 0
    abstract = ''
    pubmed_id = nil

    f_abstracts = File.open(datapath, 'r:utf-8')
    f_abstracts.each do |line|
      if /^PMID- +(?<pmid>\d+)/ =~ line
        counter += 1
        pubmed_id = pmid
        BioTCM.logger.info('PubmedGeneMiner') { "Analyzing article \##{counter}..." }
      elsif line =~ /^AB  -/
        abstract = line.gsub(/^AB  -\s*/, '').chomp
        abstract += line.gsub(/^\s+/, ' ') while (line = f_abstracts.gets.chomp) =~ /^\s/

        # Split into sentences
        sentences = abstract.split(/[.?!][\s]?/)

        # Identify genes
        genes = sentences.map { |sentence| @gene_detector.detect(sentence) }

        # Update nodes
        genes.flatten.uniq.each do |gene|
          res[gene] = [] unless res[gene]
          res[gene] << pubmed_id
        end
      end
    end

    res.select { |gene| @gene_set.include?(gene) }
  end

  private

  def as_medline(query)
    query.is_a?(BioTCM::Databases::Medline) ? query : BioTCM::Databases::Medline.new(query)
  end
end
