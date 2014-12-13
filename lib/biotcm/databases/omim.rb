# Class for retrieving OMIM entries
class BioTCM::Databases::OMIM
  extend BioTCM::Modules::WorkingDir

  # Current version of OMIM
  VERSION = '0.1.0'
  # Meta key of API key
  META_KEY = 'OMIM_API_KEY'
  # Public API key
  # (change it to your private key if in need)
  API_KEY = BioTCM.get_meta(META_KEY)
  # Url of the mim2gene.txt
  MIM2GENE_URL = 'http://biotcm.github.io/biotcm/meta/OMIM/mim2gene.txt'

  attr_reader :id, :genes

  # Get the URL for retrieving given entry
  def self.url(omim_id, api_key:API_KEY)
    return nil unless api_key
    "http://api.omim.org/api/entry?mimNumber=#{omim_id}&apiKey=#{api_key}&include=all&format=ruby"
  end
  # Create a batch of OMIM objects
  # @param omim_ids [Array]
  # @return [Hash]
  def self.batch(omim_ids)
    fail ArgumentError unless omim_ids.is_a?(Array)
    rtn = {}
    omim_ids.each do |omim_id|
      begin
        rtn[omim_id.to_i] = new(omim_id)
      rescue ArgumentError
        BioTCM.logger.warn('OMIM') { "#{omim_id} is discarded due to non-existence" }
      end
    end
    rtn
  end

  # Retrieve one OMIM entry
  # @raise ArgumentError if omim_id not exists
  def initialize(omim_id)
    # Check
    BioTCM::Databases::HGNC.ensure
    # Get the list of mimNumber
    file_path = self.class.path_to 'mim2gene.txt'
    unless File.exist?(file_path)
      fout = File.open(file_path, 'w')
      fout.puts BioTCM.get(MIM2GENE_URL)
      fout.close
    end
    @@entry_tab = Table.load(file_path) unless self.class.class_variable_defined?(:@@entry_tab)
    # Check
    fail ArgumentError, 'OMIM number not exists' unless (@id = @@entry_tab.row(omim_id.to_s))
    # Get the hash
    file_path = self.class.path_to "#{omim_id}.txt"
    unless File.exist?(file_path)
      fout = File.open(file_path, 'w')
      fout.puts BioTCM.get(self.class.url(omim_id))
      fout.close
    end
    @content = eval(File.open(file_path).read.gsub("\n", ''))['omim']['entryList'][0]['entry']
    # Find genes
    @@gene_detector = BioTCM::Apps::GeneDetector.new unless self.class.class_variable_defined?(:@@gene_detector)
    @genes = []
    @genes |= @content['phenotypeMapList']
              .collect { |h| h['phenotypeMap']['geneSymbols'].split(', ') }
              .flatten.formalize_symbol.uniq
              .reject { |sym| sym == '' } if @content['phenotypeMapExists']
    @genes |= @@gene_detector.detect(@content['textSectionList']
              .collect { |h| h['textSection']['textSectionContent'] }
              .join(' '))
  end
  # Access the returned hash for the entry
  def method_missing(symbol, *args, &block)
    super unless @content.respond_to?(symbol)
    block ? @content.send(symbol, *args, &block) : @content.send(symbol, *args)
  end
  # Jump over method_missing to speed up
  # @private
  def [](key)
    @content[key]
  end
end

BioTCM::Databases::OMIM.wd = BioTCM.path_to('data/omim')
